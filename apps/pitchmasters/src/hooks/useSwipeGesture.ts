import { useState, useRef, useCallback } from 'react';

interface SwipeGestureConfig {
  onSwipeLeft?: () => void;
  onSwipeRight?: () => void;
  threshold?: number;
  preventScroll?: boolean;
}

interface TouchCoordinates {
  x: number;
  y: number;
}

export function useSwipeGesture({
  onSwipeLeft,
  onSwipeRight,
  threshold = 50,
  preventScroll = false
}: SwipeGestureConfig) {
  const [touchStart, setTouchStart] = useState<TouchCoordinates | null>(null);
  const [touchEnd, setTouchEnd] = useState<TouchCoordinates | null>(null);
  const elementRef = useRef<HTMLElement>(null);

  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    const touch = e.targetTouches[0];
    if (touch) {
      setTouchStart({
        x: touch.clientX,
        y: touch.clientY
      });
      setTouchEnd(null);
    }
  }, []);

  const handleTouchMove = useCallback((e: React.TouchEvent) => {
    const touch = e.targetTouches[0];
    if (touch) {
      setTouchEnd({
        x: touch.clientX,
        y: touch.clientY
      });

      // Prevent scroll if needed
      if (preventScroll) {
        e.preventDefault();
      }
    }
  }, [preventScroll]);

  const handleTouchEnd = useCallback(() => {
    if (!touchStart || !touchEnd) return;

    const deltaX = touchStart.x - touchEnd.x;
    const deltaY = touchStart.y - touchEnd.y;
    const absX = Math.abs(deltaX);
    const absY = Math.abs(deltaY);

    // Only trigger swipe if horizontal movement is greater than vertical
    if (absX > absY && absX > threshold) {
      if (deltaX > 0 && onSwipeLeft) {
        onSwipeLeft();
      } else if (deltaX < 0 && onSwipeRight) {
        onSwipeRight();
      }
    }

    setTouchStart(null);
    setTouchEnd(null);
  }, [touchStart, touchEnd, threshold, onSwipeLeft, onSwipeRight]);

  const swipeHandlers = {
    onTouchStart: handleTouchStart,
    onTouchMove: handleTouchMove,
    onTouchEnd: handleTouchEnd,
    ref: elementRef
  };

  return swipeHandlers;
}