/**
 * Cloud Functions do GuIA.
 *
 * validateIAPReceipt:
 *   Callable function que valida recibos de In-App Purchase da Apple e, se
 *   válidos, marca o documento `usage/{deviceUuid}` do usuário como premium.
 *
 *   Essa é a ÚNICA forma legítima de `isPremium` virar `true` no Firestore —
 *   as security rules bloqueiam qualquer escrita do cliente nesse campo.
 *   A função usa Admin SDK, que bypassa as rules.
 *
 * Config necessária (rode no terminal antes de deployar):
 *   firebase functions:secrets:set APPLE_SHARED_SECRET
 *
 *   O shared secret é gerado em App Store Connect → Apps → GuIA →
 *   App Information → App-Specific Shared Secret.
 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

initializeApp();

// Região próxima ao Brasil para reduzir latência.
setGlobalOptions({region: "southamerica-east1", maxInstances: 10});

// Secret gerenciado pelo Secret Manager.
const APPLE_SHARED_SECRET = defineSecret("APPLE_SHARED_SECRET");

// Product IDs válidos (devem bater com o App Store Connect).
const VALID_PRODUCT_IDS = new Set(["Basic", "Prime"]);

const APPLE_PROD_URL = "https://buy.itunes.apple.com/verifyReceipt";
const APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt";

interface ValidateRequest {
  productId?: string;
  verificationData?: string; // base64 receipt (app receipt)
  source?: string;
  deviceUuid?: string; // chave do doc em usage/{deviceUuid}
}

interface AppleLatestReceiptInfo {
  product_id: string;
  expires_date_ms?: string;
  cancellation_date_ms?: string;
  original_transaction_id?: string;
}

interface AppleResponse {
  status: number;
  environment?: string;
  latest_receipt_info?: AppleLatestReceiptInfo[];
}

/**
 * Chama /verifyReceipt da Apple, com fallback prod → sandbox em status 21007.
 */
async function verifyWithApple(
  receiptData: string,
  sharedSecret: string,
): Promise<AppleResponse> {
  const body = JSON.stringify({
    "receipt-data": receiptData,
    "password": sharedSecret,
    "exclude-old-transactions": true,
  });

  const tryUrl = async (url: string): Promise<AppleResponse> => {
    const res = await fetch(url, {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body,
    });
    if (!res.ok) {
      throw new Error(`Apple verifyReceipt HTTP ${res.status}`);
    }
    return (await res.json()) as AppleResponse;
  };

  let result = await tryUrl(APPLE_PROD_URL);
  if (result.status === 21007) {
    logger.info("Receipt é de sandbox, reenviando para sandbox endpoint");
    result = await tryUrl(APPLE_SANDBOX_URL);
  }
  return result;
}

/**
 * Retorna true se existe alguma assinatura ativa (não expirada, não cancelada)
 * para um dos produtos válidos do GuIA.
 */
function hasActiveSubscription(resp: AppleResponse): boolean {
  if (resp.status !== 0) return false;
  const items = resp.latest_receipt_info || [];
  const nowMs = Date.now();
  for (const item of items) {
    if (!VALID_PRODUCT_IDS.has(item.product_id)) continue;
    if (item.cancellation_date_ms) continue;
    const expiresMs = item.expires_date_ms ?
      parseInt(item.expires_date_ms, 10) :
      0;
    if (expiresMs > nowMs) return true;
  }
  return false;
}

export const validateIAPReceipt = onCall(
  {secrets: [APPLE_SHARED_SECRET]},
  async (request) => {
    const auth = request.auth;
    if (!auth?.uid) {
      throw new HttpsError(
        "unauthenticated",
        "É necessário estar autenticado.",
      );
    }

    const data = (request.data || {}) as ValidateRequest;
    const {productId, verificationData, deviceUuid} = data;

    if (!productId || !VALID_PRODUCT_IDS.has(productId)) {
      throw new HttpsError("invalid-argument", "productId inválido.");
    }
    if (!verificationData || typeof verificationData !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "verificationData obrigatório.",
      );
    }
    if (!deviceUuid || typeof deviceUuid !== "string") {
      throw new HttpsError("invalid-argument", "deviceUuid obrigatório.");
    }

    let appleResp: AppleResponse;
    try {
      appleResp = await verifyWithApple(
        verificationData,
        APPLE_SHARED_SECRET.value(),
      );
    } catch (e) {
      logger.error("verifyWithApple failed", e);
      throw new HttpsError(
        "internal",
        "Falha ao verificar recibo na Apple.",
      );
    }

    logger.info("Apple verify result", {
      status: appleResp.status,
      env: appleResp.environment,
      uid: auth.uid,
    });

    const valid = hasActiveSubscription(appleResp);
    if (!valid) {
      return {
        valid: false,
        reason: `Apple status=${appleResp.status}, no active sub`,
      };
    }

    const db = getFirestore();
    const docRef = db.collection("usage").doc(deviceUuid);
    const snap = await docRef.get();

    if (!snap.exists) {
      // Caso raro: compra antes do app inicializar o UsageRepository.
      await docRef.set({
        authUid: auth.uid,
        dateKey: new Date().toISOString().slice(0, 10),
        aiCallsToday: 0,
        isPremium: true,
        premiumSince: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
        lastUpdated: FieldValue.serverTimestamp(),
      });
    } else {
      const docData = snap.data() || {};
      if (docData.authUid && docData.authUid !== auth.uid) {
        logger.warn("authUid mismatch em validateIAPReceipt", {
          docAuthUid: docData.authUid,
          callerUid: auth.uid,
          deviceUuid,
        });
        throw new HttpsError(
          "permission-denied",
          "Esse device pertence a outra conta.",
        );
      }
      await docRef.update({
        isPremium: true,
        premiumSince: FieldValue.serverTimestamp(),
        lastUpdated: FieldValue.serverTimestamp(),
        authUid: auth.uid,
      });
    }

    logger.info("Premium ativado", {uid: auth.uid, deviceUuid, productId});
    return {valid: true, productId};
  },
);
