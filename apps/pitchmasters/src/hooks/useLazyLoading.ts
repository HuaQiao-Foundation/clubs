import { useState, useEffect, useRef, useCallback } from 'react';

interface LazyLoadingConfig {
  threshold?: number;
  root?: Element | null;
  rootMargin?: string;
}

export function useLazyLoading<T extends HTMLElement>({
  threshold = 0.1,
  root = null,
  rootMargin = '50px'
}: LazyLoadingConfig = {}) {
  const [isIntersecting, setIsIntersecting] = useState(false);
  const [hasLoaded, setHasLoaded] = useState(false);
  const elementRef = useRef<T>(null);

  const handleIntersection = useCallback((entries: IntersectionObserverEntry[]) => {
    const [entry] = entries;
    if (entry && entry.isIntersecting && !hasLoaded) {
      setIsIntersecting(true);
      setHasLoaded(true);
    }
  }, [hasLoaded]);

  useEffect(() => {
    const observer = new IntersectionObserver(handleIntersection, {
      threshold,
      root,
      rootMargin
    });

    const currentElement = elementRef.current;
    if (currentElement) {
      observer.observe(currentElement);
    }

    return () => {
      if (currentElement) {
        observer.unobserve(currentElement);
      }
    };
  }, [handleIntersection, threshold, root, rootMargin]);

  return {
    elementRef,
    isIntersecting,
    hasLoaded
  };
}

// Hook for virtualizing long lists on mobile
export function useVirtualScrolling<T>(
  items: T[],
  itemHeight: number,
  containerHeight: number,
  overscan: number = 5
) {
  const [scrollTop, setScrollTop] = useState(0);
  const scrollElementRef = useRef<HTMLDivElement>(null);

  const handleScroll = useCallback((e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  }, []);

  const visibleStart = Math.floor(scrollTop / itemHeight);
  const visibleEnd = Math.min(
    visibleStart + Math.ceil(containerHeight / itemHeight),
    items.length
  );

  const startIndex = Math.max(0, visibleStart - overscan);
  const endIndex = Math.min(items.length, visibleEnd + overscan);

  const visibleItems = items.slice(startIndex, endIndex);
  const offsetY = startIndex * itemHeight;
  const totalHeight = items.length * itemHeight;

  return {
    visibleItems,
    startIndex,
    endIndex,
    offsetY,
    totalHeight,
    scrollElementRef,
    handleScroll
  };
}