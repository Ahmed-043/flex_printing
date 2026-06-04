self.onmessage = async (event) => {
  const data = event.data || {};
  const id = data.id;

  const maxWidth = 1920;
  const maxHeight = 1080;
  const highQuality = 0.9;
  const lowQuality = 0.6;

  try {
    const input = data.bytes;
    const inputBytes =
      input instanceof Uint8Array ? input : new Uint8Array(input);
    const originalLength = inputBytes.byteLength;

    if (originalLength <= 250 * 1024) {
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

    let bitmap;
    try {
      bitmap = await createImageBitmap(blob);
    } catch (error) {
      throw new Error(
        error && error.message ? error.message : String(error)
      );
    }

    const widthScale = maxWidth / bitmap.width;
    const heightScale = maxHeight / bitmap.height;
    const scale = Math.min(widthScale, heightScale);

    const targetWidth = scale < 1
      ? Math.max(1, Math.min(maxWidth, Math.round(bitmap.width * scale)))
      : bitmap.width;
    const targetHeight = scale < 1
      ? Math.max(1, Math.min(maxHeight, Math.round(bitmap.height * scale)))
      : bitmap.height;

    const canvas = new OffscreenCanvas(targetWidth, targetHeight);
    const context = canvas.getContext('2d');
    if (!context) {
      bitmap.close();
      throw new Error('Failed to obtain 2D canvas context.');
    }

    context.imageSmoothingEnabled = true;
    context.imageSmoothingQuality = 'high';

    if (scale < 1) {
      context.drawImage(
        bitmap,
        0,
        0,
        bitmap.width,
        bitmap.height,
        0,
        0,
        targetWidth,
        targetHeight,
      );
    } else {
      context.drawImage(bitmap, 0, 0);
    }
    bitmap.close();

    const quality = originalLength > 800 * 1024 ? lowQuality : highQuality;
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
