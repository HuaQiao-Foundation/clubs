interface PHFPinProps {
  size?: number
  className?: string
}

export default function PHFPin({ size = 16, className = "" }: PHFPinProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 20 20"
      className={className}
      role="img"
      aria-label="Paul Harris Fellow"
    >
      <title>Paul Harris Fellow</title>
      {/* Gold Ring - Thicker */}
      <circle
        cx="10"
        cy="10"
        r="9"
        fill="#f7a81b"
        stroke="none"
      />

      {/* Sapphire Center - Smaller */}
      <circle
        cx="10"
        cy="10"
        r="4"
        fill="#0067c8"
        stroke="none"
      />
    </svg>
  )
}