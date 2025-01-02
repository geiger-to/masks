import { gql } from "@urql/svelte";

export const ClientFragment = gql`
  fragment ClientFragment on Client {
    id
    secret
    checks
    scopes
    redirectUris
    subjectType
    name
    type
    logo
    bgLight
    bgDark
    sectorIdentifier
    pairwiseSalt
    allowPasswords
    allowLoginLinks
    autofillRedirectUri
    fuzzyRedirectUri
    idTokenExpiresIn
    accessTokenExpiresIn
    authorizationCodeExpiresIn
    refreshTokenExpiresIn
    loginLinkExpiresIn
    authAttemptExpiresIn
    emailVerificationExpiresIn
    loginLinkFactorExpiresIn
    passwordFactorExpiresIn
    secondFactorBackupCodeExpiresIn
    secondFactorPhoneExpiresIn
    secondFactorTotpCodeExpiresIn
    secondFactorWebauthnExpiresIn
    internalTokenExpiresIn
    lifetimeTypes
    stats
    createdAt
    updatedAt
  }
`;

export const TokenFragment = gql`
  fragment TokenFragment on Token {
    id
    type
    secret
    usable
    expired
    redirectUri
    scopes
    nonce
    createdAt
    expiresAt
    revokedAt
    client {
      id
      name
    }
    actor {
      id
      name
      identifier
      identiconId
    }
    device {
      id
      name
      type
      ip
      os
    }
  }
`;

export const DeviceFragment = gql`
  fragment DeviceFragment on Device {
    id
    name
    type
    ip
    os
    userAgent
    version
    createdAt
    updatedAt
    blockedAt
  }
`;

export const LogoutMutation = gql`
  mutation ($input: LogoutInput!) {
    logout(input: $input) {
      total
      errors
    }
  }
`;

function redirectTimeout(cb, timeout = 300) {
  const thresholdMillis = 5000;
  const lastReloadTimestamp = parseInt(
    localStorage.getItem("lastReloadTimestamp") || "0",
    10
  );
  const currentTimestamp = Date.now();

  if (currentTimestamp - lastReloadTimestamp < thresholdMillis) {
    return;
  }

  localStorage.setItem("lastReloadTimestamp", currentTimestamp.toString());

  setTimeout(cb, timeout);
}

export { redirectTimeout };
