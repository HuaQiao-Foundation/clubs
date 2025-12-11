import React, { useState, useEffect, useRef } from 'react';

interface ResponsiveImageProps {
  src: string;
  alt: string;
  className?: string;
  loading?: 'lazy' | 'eager';
  priority?: boolean;
  sizes?: string;
  style?: React.CSSProperties;
}

export const ResponsiveImage: React.FC<ResponsiveImageProps> = ({
  src,
  alt,
  className = '',
  loading = 'lazy',
  priority = false,
  sizes = '100vw',
  style = {}
}) => {
  const [isInView, setIsInView] = useState(priority);
  const [hasLoaded, setHasLoaded] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    if (priority || loading === 'eager') {
      setIsInView(true);
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsInView(true);
            observer.disconnect();
          }
        });
      },
      {
        rootMargin: '50px'
      }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, [priority, loading]);

  const imageStyle: React.CSSProperties = {
    ...style,
    opacity: hasLoaded ? 1 : 0,
    transition: 'opacity 0.3s ease-in-out'
  };

  const placeholderStyle: React.CSSProperties = {
    backgroundColor: '#f0f0f0',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: -1
  };

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <div style={placeholderStyle} />
      <img
        ref={imgRef}
        src={isInView ? src : undefined}
        alt={alt}
        className={className}
        sizes={sizes}
        loading={loading}
        onLoad={() => setHasLoaded(true)}
        style={imageStyle}
        fetchPriority={priority ? 'high' : undefined}
      />
    </div>
  );
};

export default ResponsiveImage;