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
