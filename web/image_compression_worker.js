self.onmessage = async (event) => {
  const data = event.data || {};
  const id = data.id;

  try {
    const input = data.bytes;
    const inputBytes =
      input instanceof Uint8Array ? input : new Uint8Array(input);
    const originalLength = inputBytes.byteLength;

    if (originalLength <= 500 * 1024) {
      const passthrough = inputBytes.slice().buffer;
      self.postMessage([id, passthrough, null], [passthrough]);
      return;
    }

    if (
      typeof OffscreenCanvas === 'undefined' ||
      typeof createImageBitmap === 'undefined'
    ) {
      throw new Error('Required worker image APIs are unavailable.');
    }

    const blob = new Blob([inputBytes]);
    const bitmap = await createImageBitmap(blob);

    const maxWidth = 1920;
    const maxHeight = 1080;

    let targetWidth = bitmap.width;
    let targetHeight = bitmap.height;

    const widthScale = maxWidth / bitmap.width;
    const heightScale = maxHeight / bitmap.height;
    const scale = Math.min(widthScale, heightScale);

    if (scale < 1) {
      targetWidth = Math.max(1, Math.min(maxWidth, Math.round(bitmap.width * scale)));
      targetHeight = Math.max(
        1,
        Math.min(maxHeight, Math.round(bitmap.height * scale))
      );
    }

    const canvas = new OffscreenCanvas(targetWidth, targetHeight);
    const context = canvas.getContext('2d');
    if (!context) {
      throw new Error('Failed to obtain 2D canvas context.');
    }
    context.drawImage(bitmap, 0, 0, targetWidth, targetHeight);
    bitmap.close();

    const quality = originalLength > 1200 * 1024 ? 0.4 : 0.7;
    const compressedBlob = await canvas.convertToBlob({
      type: 'image/jpeg',
      quality,
    });
    const compressedBuffer = await compressedBlob.arrayBuffer();
    self.postMessage([id, compressedBuffer, null], [compressedBuffer]);
  } catch (error) {
    self.postMessage([id, null, error && error.message ? error.message : String(error)]);
  }
};
