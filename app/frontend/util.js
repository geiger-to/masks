import { gql } from "@urql/svelte";

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

export const EntryFragment = gql`
  fragment EntryFragment on Entry {
    actor {
      id
      name
      identifier
      identiconId
    }
    device {
      ...DeviceFragment
    }
    client {
      id
      name
    }
    createdAt
  }

  ${DeviceFragment}
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
