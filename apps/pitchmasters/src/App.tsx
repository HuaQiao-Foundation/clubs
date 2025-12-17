import { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import MembersPage from './pages/MembersPage';
import MemberProfilePage from './pages/MemberProfilePage';
import CommunityPage from './pages/CommunityPage';
import FaviconTestPage from './pages/FaviconTestPage';
import { usePerformanceMetrics } from './hooks/usePerformanceMetrics';
import { UpdatePrompt } from './components/UpdatePrompt';
import { OfflineIndicator } from './components/OfflineIndicator';

function App() {
  const { logMetrics, isGoodLCP, isGoodCLS, isGoodFCP } = usePerformanceMetrics();

  useEffect(() => {
    // Log performance metrics in development after page load
    if (import.meta.env.DEV) {
      const timer = setTimeout(() => {
        logMetrics();
        console.log('Performance Status:', {
          LCP: isGoodLCP ? '✅ Good' : '⚠️ Needs improvement',
          CLS: isGoodCLS ? '✅ Good' : '⚠️ Needs improvement',
          FCP: isGoodFCP ? '✅ Good' : '⚠️ Needs improvement'
        });
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [logMetrics, isGoodLCP, isGoodCLS, isGoodFCP]);

  return (
    <>
      <BrowserRouter>
        <Layout>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/members" element={<MembersPage />} />
            <Route path="/members/:memberId" element={<MemberProfilePage />} />
            <Route path="/community" element={<CommunityPage />} />
            <Route path="/favicon-test" element={<FaviconTestPage />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Layout>
      </BrowserRouter>
      <UpdatePrompt />
      <OfflineIndicator />
    </>
  );
}

export default App;