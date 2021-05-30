export function toCenter(id: string) {
  const el = document.getElementById(id);
  if (el) {
    el.scrollIntoView({ block: "center" });
  }
}
