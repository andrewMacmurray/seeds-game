import { gsap } from "gsap";

// Animation Element

abstract class AnimationElement extends HTMLElement {
  type: "timeline" | "keyframes" | "tween";

  abstract buildAnimation(): gsap.core.Animation | undefined;
  abstract get position(): string | undefined;

  isRootAnimation(): boolean {
    const parent = this.parentElement as AnimationElement;
    return parent && parent.type !== "timeline";
  }

  get _subject() {
    return this._target ? `.${this.className} ${this._target}` : this._children;
  }

  private get _target(): string | undefined {
    return this.parseAttribute("animation")["target"];
  }

  animationEvents() {
    return {
      onComplete: () => this.gsapEvent("gsapanimationcomplete"),
      onStart: () => this.gsapEvent("gsapanimationstart"),
      onRepeat: () => this.gsapEvent("gsapanimationrepeat")
    };
  }

  private gsapEvent(eventName: string) {
    this.dispatchEvent(new Event(eventName));
  }

  parseAttribute<T>(attribute: string): T | undefined {
    const a = this.getAttribute(attribute);
    return a ? JSON.parse(a) : undefined;
  }

  generateClassName(): string {
    const randomString = Math.random()
      .toString(36)
      .substring(2);
    return `${this.type}-${randomString}`;
  }

  get _children(): AnimationElement[] | undefined {
    if (this.children && this.children.length > 0) {
      return Array.from(this.children) as AnimationElement[];
    }
  }
}

// Tween

class TweenElement extends AnimationElement {
  readonly type = "tween";

  static get observedAttributes() {
    return ["animation"];
  }

  connectedCallback() {
    this.className = this.generateClassName();
    if (this.isRootAnimation()) {
      this.buildAnimation();
    }
  }

  attributeChangedCallback() {
    this.buildAnimation();
  }

  buildAnimation(): gsap.core.Animation | undefined {
    const to = this._to;
    const from = this._from;
    const events = this.animationEvents();
    if (this._children) {
      if (from && to) {
        return gsap.fromTo(this._subject, from, { ...to, ...events });
      } else if (from) {
        return gsap.from(this._subject, { ...from, ...events });
      } else if (to) {
        return gsap.to(this._subject, { ...to, ...events });
      }
    }
  }

  get position(): string | undefined {
    return this.parseAttribute("animation")["position"];
  }

  private get _to(): gsap.TweenVars | undefined {
    return this.parseAttribute("animation")["to"];
  }

  private get _from(): gsap.TweenVars | undefined {
    return this.parseAttribute("animation")["from"];
  }
}

//  Keyframes

class KeyframesElement extends AnimationElement {
  readonly type = "keyframes";

  connectedCallback() {
    if (this.isRootAnimation()) {
      this.buildAnimation();
    }
  }

  buildAnimation(): gsap.core.Animation | undefined {
    if (this._animationVars && this._children) {
      return gsap.timeline().to(this._subject, {
        ...this._animationVars,
        ...this.animationEvents()
      });
    }
  }

  get position(): string | undefined {
    return this.getAttribute("position");
  }

  private get _animationVars(): gsap.AnimationVars | undefined {
    return this.parseAttribute("animation");
  }
}

// Timeline

class TimelineElement extends AnimationElement {
  readonly type = "timeline";

  connectedCallback() {
    if (this.isRootAnimation()) {
      this.buildAnimation();
    }
  }

  buildAnimation(): gsap.core.Animation | undefined {
    return this._animationVars && this._children
      ? this.buildTimeline()
      : undefined;
  }

  private buildTimeline(): gsap.core.Animation {
    const timeline = gsap.timeline({
      ...this._animationVars,
      ...this.animationEvents()
    });
    this._children.forEach(child => this.addToTimeline(child, timeline));
    return timeline;
  }

  get position(): string | undefined {
    return this.getAttribute("position");
  }

  private addToTimeline(child: AnimationElement, timeline: gsap.core.Timeline) {
    timeline.add(child.buildAnimation(), child.position);
  }

  private get _animationVars(): gsap.AnimationVars | undefined {
    return this.parseAttribute("animation");
  }
}

// Define

document.addEventListener("DOMContentLoaded", () => {
  customElements.define("tween-element", TweenElement);
  customElements.define("keyframes-element", KeyframesElement);
  customElements.define("timeline-element", TimelineElement);
});
