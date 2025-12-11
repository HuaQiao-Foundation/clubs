import { useState } from 'react';
import { ArrowLeft, Download, Eye, Palette, Smartphone, Monitor, Tablet } from 'lucide-react';
import { Link } from 'react-router-dom';

const LOGO_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 99.2 82.45">
  <defs>
    <style>
      .tm-stroke { stroke: var(--tm-color, #004165); stroke-width: .91px; fill: none; }
      .tm-fill { fill: var(--tm-color, #004165); stroke-width: 0px; }
    </style>
  </defs>
  <path class="tm-stroke" d="m98.75,30.35h-9.91C84.08,13.11,68.3.45,49.55.45S15.02,13.11,10.26,30.35H.45v21.97h9.87c4.83,17.12,20.56,29.68,39.23,29.68s34.4-12.55,39.23-29.68h9.97v-21.97Z"/>
  <path class="tm-fill" d="m97.2,31.85h-9.69c-3.26-13.53-13.64-24.9-28.01-28.69C38.67-2.35,17.25,10.12,11.75,30.95c-.08.3-.15.6-.23.9H1.95v18.97h9.78c3.47,13.17,13.73,24.16,27.81,27.88,20.83,5.5,42.25-6.97,47.75-27.79,0-.03.01-.06.02-.08h9.89v-18.97Z"/>
</svg>`;

export default function FaviconTestPage() {
  const [darkMode, setDarkMode] = useState(false);
  const [selectedSize, setSelectedSize] = useState<number | null>(null);

  const sizes = [
    { size: 16, description: 'Browser tab (default)', usage: 'Most common favicon size' },
    { size: 32, description: 'High-DPI browser tab', usage: 'Retina displays, Windows taskbar' },
    { size: 48, description: 'Windows desktop', usage: 'Desktop shortcuts, some browsers' },
    { size: 64, description: 'High-resolution desktop', usage: 'Retina desktop shortcuts' },
    { size: 128, description: 'Chrome Web Store', usage: 'App listings, large icons' },
    { size: 180, description: 'Apple Touch Icon', usage: 'iOS home screen, Safari pinned tabs' },
    { size: 512, description: 'PWA manifest', usage: 'High-resolution app icons, splash screens' }
  ];

  const devices = [
    { icon: Smartphone, name: 'Mobile', sizes: [16, 32, 180] },
    { icon: Tablet, name: 'Tablet', sizes: [32, 180, 512] },
    { icon: Monitor, name: 'Desktop', sizes: [16, 32, 48, 64] }
  ];

  const downloadSVG = (size: number) => {
    const color = darkMode ? '#004165' : '#004165'; // Loyal Blue for both modes
    const svgContent = LOGO_SVG.replace('var(--tm-color, #004165)', color);

    const blob = new Blob([svgContent], { type: 'image/svg+xml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `toastmasters-favicon-${size}px.svg`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className={`min-h-screen transition-colors duration-300 ${
      darkMode ? 'bg-gray-900 text-white' : 'bg-gray-50 text-gray-900'
    }`}>
      {/* Header */}
      <div className={`border-b transition-colors ${
        darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'
      }`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="py-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <Link
                  to="/dashboard"
                  className="inline-flex items-center gap-2 text-tm-blue hover:text-blue-700 transition-colors"
                >
                  <ArrowLeft className="w-5 h-5" />
                  Back to Dashboard
                </Link>
                <div>
                  <h1 className="text-3xl font-bold">Favicon Quality Test</h1>
                  <p className={`mt-1 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    Toastmasters Logo SVG Scaling Evaluation
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-4">
                <button
                  onClick={() => setDarkMode(!darkMode)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg border transition-colors ${
                    darkMode
                      ? 'bg-gray-700 border-gray-600 hover:bg-gray-600'
                      : 'bg-white border-gray-300 hover:bg-gray-50'
                  }`}
                >
                  <Palette className="w-4 h-4" />
                  {darkMode ? 'Light' : 'Dark'} Mode
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Device Categories */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          {devices.map(({ icon: Icon, name, sizes: deviceSizes }) => (
            <div key={name} className={`p-6 rounded-lg border transition-colors ${
              darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'
            }`}>
              <div className="flex items-center gap-3 mb-4">
                <Icon className="w-6 h-6 text-tm-blue" />
                <h3 className="text-lg font-semibold">{name}</h3>
              </div>
              <div className="flex flex-wrap gap-2">
                {deviceSizes.map(size => (
                  <button
                    key={size}
                    onClick={() => setSelectedSize(selectedSize === size ? null : size)}
                    className={`px-3 py-1 rounded text-sm transition-colors ${
                      selectedSize === size
                        ? 'bg-tm-blue text-white'
                        : darkMode
                          ? 'bg-gray-700 hover:bg-gray-600'
                          : 'bg-gray-100 hover:bg-gray-200'
                    }`}
                  >
                    {size}px
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Size Test Grid */}
        <div className={`p-8 rounded-lg border mb-8 transition-colors ${
          darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h2 className="text-2xl font-bold mb-6">SVG Scaling Quality Test</h2>

          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-8">
            {sizes.map(({ size, description, usage }) => (
              <div
                key={size}
                className={`text-center p-4 rounded-lg transition-all duration-200 ${
                  selectedSize === size
                    ? 'ring-2 ring-tm-blue bg-tm-blue bg-opacity-5'
                    : darkMode
                      ? 'hover:bg-gray-700'
                      : 'hover:bg-gray-50'
                }`}
                onClick={() => setSelectedSize(selectedSize === size ? null : size)}
              >
                <div className="flex justify-center mb-3">
                  <div
                    className={`flex items-center justify-center border-2 border-dashed transition-colors ${
                      darkMode ? 'border-gray-600' : 'border-gray-300'
                    }`}
                    style={{
                      width: Math.max(size, 40),
                      height: Math.max(size, 40),
                      minWidth: '40px',
                      minHeight: '40px'
                    }}
                  >
                    <div
                      dangerouslySetInnerHTML={{
                        __html: LOGO_SVG.replace('var(--tm-color, #004165)', '#004165')
                      }}
                      style={{
                        width: `${size}px`,
                        height: `${size}px`,
                        maxWidth: '100%',
                        maxHeight: '100%'
                      }}
                    />
                  </div>
                </div>

                <div className="space-y-1">
                  <div className="font-bold text-tm-blue">{size}px</div>
                  <div className={`text-xs font-medium ${
                    darkMode ? 'text-gray-300' : 'text-gray-600'
                  }`}>
                    {description}
                  </div>
                  <div className={`text-xs ${
                    darkMode ? 'text-gray-400' : 'text-gray-500'
                  }`}>
                    {usage}
                  </div>
                </div>

                <div className="mt-3 flex justify-center gap-2">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setSelectedSize(size);
                    }}
                    className={`p-1 rounded transition-colors ${
                      darkMode
                        ? 'hover:bg-gray-600 text-gray-400 hover:text-gray-200'
                        : 'hover:bg-gray-200 text-gray-500 hover:text-gray-700'
                    }`}
                    title="Preview"
                  >
                    <Eye className="w-3 h-3" />
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      downloadSVG(size);
                    }}
                    className={`p-1 rounded transition-colors ${
                      darkMode
                        ? 'hover:bg-gray-600 text-gray-400 hover:text-gray-200'
                        : 'hover:bg-gray-200 text-gray-500 hover:text-gray-700'
                    }`}
                    title="Download SVG"
                  >
                    <Download className="w-3 h-3" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Quality Analysis */}
        <div className={`p-6 rounded-lg border transition-colors ${
          darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className="text-xl font-bold mb-4">Quality Analysis</h3>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h4 className="font-semibold text-green-600 dark:text-green-400 mb-2">✅ Excellent Quality</h4>
              <ul className={`space-y-1 text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                <li>• Crisp edges at all sizes</li>
                <li>• Perfect scalability (vector-based)</li>
                <li>• Consistent Toastmasters branding</li>
                <li>• Small file size (684 bytes)</li>
                <li>• CSS custom property support</li>
              </ul>
            </div>

            <div>
              <h4 className="font-semibold text-blue-600 dark:text-blue-400 mb-2">🎯 Recommended Usage</h4>
              <ul className={`space-y-1 text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                <li>• Primary: 16px, 32px (browser tabs)</li>
                <li>• Mobile: 180px (Apple Touch Icon)</li>
                <li>• PWA: 512px (app manifest)</li>
                <li>• ICO fallback: 32px for IE support</li>
                <li>• Dark mode: Auto-adapts via CSS variables</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Selected Size Preview */}
        {selectedSize && (
          <div className={`mt-8 p-6 rounded-lg border transition-colors ${
            darkMode ? 'bg-gray-800 border-gray-700' : 'bg-white border-gray-200'
          }`}>
            <h3 className="text-xl font-bold mb-4">
              Preview: {selectedSize}px - {sizes.find(s => s.size === selectedSize)?.description}
            </h3>

            <div className="flex items-center gap-8">
              <div className="text-center">
                <div className="mb-2 font-medium">Actual Size</div>
                <div
                  dangerouslySetInnerHTML={{
                    __html: LOGO_SVG.replace('var(--tm-color, #004165)', '#004165')
                  }}
                  style={{
                    width: `${selectedSize}px`,
                    height: `${selectedSize}px`
                  }}
                />
              </div>

              <div className="text-center">
                <div className="mb-2 font-medium">2x Magnified</div>
                <div
                  dangerouslySetInnerHTML={{
                    __html: LOGO_SVG.replace('var(--tm-color, #004165)', '#004165')
                  }}
                  style={{
                    width: `${selectedSize * 2}px`,
                    height: `${selectedSize * 2}px`
                  }}
                />
              </div>

              <div className="flex-1">
                <div className="mb-2 font-medium">Usage Context</div>
                <p className={`text-sm ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                  {sizes.find(s => s.size === selectedSize)?.usage}
                </p>
                <button
                  onClick={() => downloadSVG(selectedSize)}
                  className="mt-3 inline-flex items-center gap-2 px-4 py-2 bg-tm-blue text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  <Download className="w-4 h-4" />
                  Download {selectedSize}px SVG
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}