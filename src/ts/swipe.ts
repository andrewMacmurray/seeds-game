const threshold = 30;

export function onRight(cb: () => void) {
  let start = 0;
  
  document.addEventListener("pointerdown", (e) => {
    start = e.clientX;
  });
  
  document.addEventListener("pointerup", (e) => {
    if (isSwipeRight(e, start)) {
      cb();
    }
    start = 0;
  });
}

function isSwipeRight(e: PointerEvent, start: number): boolean {
  return e.clientX - start > threshold;
}