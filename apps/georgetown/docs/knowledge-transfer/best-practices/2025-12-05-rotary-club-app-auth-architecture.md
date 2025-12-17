# Georgetown Rotary Club App - Authentication Architecture Briefing

**Date**: 2025-12-05
**From**: CEO (Randal)
**To**: CTO (Claude Code)
**Subject**: Critical authentication lessons from Hub debugging for Rotary Club app setup
**Priority**: HIGH - Apply BEFORE building auth system

---

## Executive Summary

We just debugged a critical Hub authentication bug that prevented users from logging in. The root causes were architectural decisions that created race conditions, async rendering issues, and token validation failures. **Apply these lessons to the Rotary Club app from day one** to avoid the same problems.

**Bottom Line**: Authentication is the foundation. Get it right initially, or you'll spend hours debugging production login failures.

---

## Context: What We Just Fixed in Hub

### The Problem
- Login page showed infinite spinner instead of form
- "Invalid Refresh Token" errors prevented page load
- Users couldn't authenticate from mobile/incognito browsers
- Race conditions between React Admin, Supabase, and custom AuthGate component

### Root Causes (3 layers)
1. **UI Layer**: Async route checking caused spinner flash
2. **Storage Layer**: Expired tokens triggered errors before React mounted
3. **Context Layer**: Login components used React Admin hooks outside context

### The Fix (3 hours of debugging)
- Synchronous public route detection
- Token validation at storage boundary
- Direct Supabase auth (no React Admin hooks on login page)
- Graceful error handling with state machines

**Lesson**: These issues were 100% preventable with correct initial architecture.

---

## Critical Lessons for Rotary Club App

### Lesson 1: Never Use Async Checks for Routing Decisions

**Hub Mistake**:
```typescript
// ❌ BAD: Async check in useEffect
const [isPublic, setIsPublic] = useState(false);

useEffect(() => {
  const check = publicRoutes.includes(location.pathname);
  setIsPublic(check);
}, [location]);

if (!isPublic) return <Spinner />; // First render ALWAYS shows spinner
```

**First render**: `isPublic = false` (default) → spinner shows
**After useEffect**: `isPublic = true` → form renders
**User sees**: 50-500ms spinner flash (bad UX)

**Rotary Club Solution**:
```typescript
// ✅ GOOD: Synchronous check in component body
const isPublicRoute = publicRoutes.some(route =>
  location.pathname.includes(route) || location.hash.includes(route)
);

if (isPublicRoute) return <LoginForm />; // Immediate render, no flash
```

**Architecture Rule**: **Routing decisions MUST be synchronous. No useEffect for "what should I render?"**

---

### Lesson 2: Validate Auth Tokens at Storage Boundary

**Hub Mistake**: Supabase automatically tried to restore expired tokens from localStorage, causing errors before React even rendered.

**Timeline of Failure**:
- T+0ms: JavaScript imports supabase.ts
- T+10ms: Supabase reads expired token from localStorage
- T+50ms: POST /auth/v1/token 400 (refresh fails)
- T+100ms: React starts rendering
- **Error happened BEFORE React could handle it**

**Rotary Club Solution**:
```typescript
// Custom storage wrapper validates tokens BEFORE Supabase sees them
const validatedStorage = {
  getItem: (key: string) => {
    const raw = localStorage.getItem(key);
    if (!raw) return null;

    // For auth tokens, validate before returning
    if (key.includes('supabase.auth.token')) {
      try {
        const data = JSON.parse(raw);
        const expiresAt = data.expires_at * 1000;
        const now = Date.now();
        const buffer = 60 * 1000; // 1 minute

        if (expiresAt < now + buffer) {
          localStorage.removeItem(key); // Remove expired token
          return null; // Supabase won't try to refresh
        }
      } catch {
        localStorage.removeItem(key); // Remove invalid token
        return null;
      }
    }

    return raw;
  },
  setItem: (key: string, value: string) => localStorage.setItem(key, value),
  removeItem: (key: string) => localStorage.removeItem(key),
};

const supabase = createClient(url, key, {
  auth: {
    storage: validatedStorage, // Use custom storage
  }
});
```

**Why This Works**:
- Expired tokens removed BEFORE Supabase reads them
- No failed refresh attempts
- No console errors on page load
- Clean initial state

**Architecture Rule**: **Validate data at the boundary, not after consumption.**

---

### Lesson 3: Authentication State Machine

**Hub Mistake**: No clear definition of valid auth states. Components had conflicting ideas about "is user authenticated?"

**Rotary Club Solution**: Define explicit auth states and valid transitions.

```typescript
type AuthState =
  | { status: 'initial' }           // App just loaded
  | { status: 'checking' }          // Auth check in progress
  | { status: 'authenticated'; user: User }  // Logged in
  | { status: 'guest' }             // Not logged in

// Valid transitions:
// initial → checking → authenticated ✅
// initial → checking → guest ✅
// authenticated → checking → guest (logout) ✅

// Invalid transitions (prevent these):
// initial → authenticated (skip validation) ❌
// checking → authenticated (skip validation) ❌
// guest → authenticated (skip login) ❌
```

**Implementation**:
```typescript
const [authState, setAuthState] = useState<AuthState>({ status: 'initial' });

useEffect(() => {
  setAuthState({ status: 'checking' });

  supabase.auth.getSession().then(({ data: { session } }) => {
    if (session) {
      setAuthState({ status: 'authenticated', user: session.user });
    } else {
      setAuthState({ status: 'guest' });
    }
  });
}, []);

// Render based on state (no intermediate broken states)
switch (authState.status) {
  case 'initial':
  case 'checking':
    return <LoadingScreen />;
  case 'authenticated':
    return <Dashboard user={authState.user} />;
  case 'guest':
    return <LoginPage />;
}
```

**Architecture Rule**: **Define valid states and transitions upfront. Prevent invalid state combinations.**

---

### Lesson 4: Login Page Cannot Use Framework Auth Hooks

**Hub Mistake**: Login page used React Admin hooks (`useLogin`, `useNotify`) that required being inside `<Admin>` component. But login page renders OUTSIDE `<Admin>` → infinite Suspense boundary.

**Rotary Club Solution**: Login page uses Supabase client directly.

```typescript
// ✅ GOOD: Direct Supabase auth (no framework dependencies)
export const LoginPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setError(error.message);
    } else {
      window.location.href = '/dashboard'; // Manual redirect
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
      {error && <p>{error}</p>}
      <button type="submit">Sign In</button>
    </form>
  );
};
```

**Architecture Rule**: **Public pages (login, signup, forgot password) must be framework-agnostic. Use auth client directly.**

---

### Lesson 5: Comprehensive Logging from Day One

**Hub Mistake**: No logging. When login broke, we had zero visibility into where the failure occurred.

**Rotary Club Solution**: Log every auth decision with context.

```typescript
const logger = {
  info: (msg: string, context?: any) => {
    if (import.meta.env.DEV) {
      console.log(`[Auth] ${msg}`, context);
    }
  },
  error: (msg: string, context?: any) => {
    console.error(`[Auth] ERROR: ${msg}`, context);
    // Send to Sentry/LogRocket in production
  },
};

// Log route decisions
logger.info('Route check', {
  pathname: location.pathname,
  isPublicRoute,
  decision: isPublicRoute ? 'render login' : 'check auth'
});

// Log auth check progress
logger.info('Auth check started');
const result = await supabase.auth.getSession();
logger.info('Auth check completed', {
  hasSession: !!result.data.session,
  userId: result.data.session?.user.id
});

// Log errors
logger.error('Auth check failed', {
  error: error.message,
  code: error.code,
  route: location.pathname
});
```

**What to Log**:
- Route checks (public vs protected)
- Auth check start/complete (with duration)
- Token validation (expired vs valid)
- State transitions (initial → checking → authenticated)
- Errors (with full context)

**Architecture Rule**: **Log auth decisions BEFORE they cause problems, not after.**

---

## Rotary Club App Authentication Architecture

### Tech Stack Recommendation

**DO use**:
- **Supabase Auth** (proven, well-documented, same as Hub)
- **React Router** (simple, no hash routing complexity)
- **TypeScript** (catch auth state errors at compile time)
- **Vite** (fast dev server, easy env var handling)

**DON'T use** (lessons from Hub):
- React Admin (unless you need full admin UI framework - adds complexity)
- Hash routing (makes URL handling harder - use regular routing)
- Client-side auth hooks on login page (creates context issues)

### Proposed Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Supabase Client (Token Management)                │
│ - Custom storage validates tokens before use               │
│ - 1-minute expiry buffer                                   │
│ - Automatic cleanup of expired/invalid tokens              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Auth Context (State Management)                   │
│ - Explicit auth state machine                              │
│ - Valid state transitions enforced                         │
│ - User profile caching with TTL                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Route Guard (UI Protection)                       │
│ - Synchronous public route detection                       │
│ - Protected routes check auth before render                │
│ - Clean loading states (no spinner flash)                  │
└─────────────────────────────────────────────────────────────┘
```

### File Structure

```
src/
├── lib/
│   ├── supabase.ts              # Supabase client with validated storage
│   └── auth-logger.ts           # Centralized auth logging
├── contexts/
│   └── AuthContext.tsx          # Auth state machine
├── components/
│   ├── auth/
│   │   ├── LoginPage.tsx        # Public page, no framework hooks
│   │   ├── SignupPage.tsx       # Public page
│   │   └── ForgotPassword.tsx   # Public page
│   └── guards/
│       └── AuthGuard.tsx        # Synchronous route protection
└── hooks/
    └── useAuth.ts               # Consume auth context (protected routes only)
```

---

## Implementation Checklist

### Phase 1: Foundation (Do This First)

- [ ] **Supabase client with validated storage** (prevents token errors)
  - Custom storage wrapper
  - Token expiry validation (1-minute buffer)
  - Invalid token cleanup

- [ ] **Auth state machine** (clear state definitions)
  - Define AuthState type
  - Valid transitions only
  - No intermediate broken states

- [ ] **Comprehensive logging** (debugging visibility)
  - Log route checks
  - Log auth checks (start/complete)
  - Log state transitions
  - Log errors with context

### Phase 2: Routes (Do This Second)

- [ ] **Public routes** (login, signup, forgot password)
  - NO framework auth hooks
  - Direct Supabase client usage
  - Synchronous route detection

- [ ] **Protected routes** (dashboard, profile, settings)
  - AuthGuard component
  - Synchronous auth check
  - Clear loading states

### Phase 3: Testing (Do This Before Production)

- [ ] **Unit tests**
  - Token validation (expired, valid, invalid)
  - Auth state transitions
  - Route guard logic

- [ ] **Integration tests**
  - Full login flow (fresh browser → login → dashboard)
  - Expired token handling
  - Session auto-redirect

- [ ] **E2E tests** (Playwright)
  - Login from mobile viewport
  - Login from incognito browser
  - Logout and re-login

---

## Common Pitfalls to Avoid

### 1. "I'll add logging later"
**NO.** Add logging from day one. When auth breaks in production, you'll have zero visibility without logs.

### 2. "I'll use the framework's auth system"
**MAYBE.** If the framework requires hooks on public pages, you'll hit the same context issue we had. Use Supabase directly on login/signup pages.

### 3. "I'll handle expired tokens in the UI"
**NO.** Handle expired tokens at the storage layer. Prevent errors before they occur.

### 4. "I'll use useEffect to check routes"
**NO.** Route checks must be synchronous. useEffect causes spinner flash.

### 5. "I'll copy the Hub auth code"
**NO.** The Hub auth code evolved through 3 iterations of bugs. Start fresh with the lessons learned.

---

## Testing Strategy

### Must-Have Tests

**Scenario 1: Fresh Browser**
```typescript
test('fresh browser shows login form immediately', async ({ page }) => {
  await page.goto('http://localhost:5173/login');

  // Login form should appear in <500ms (no spinner flash)
  const startTime = Date.now();
  await page.waitForSelector('input[type="email"]');
  const loadTime = Date.now() - startTime;

  expect(loadTime).toBeLessThan(500);
});
```

**Scenario 2: Expired Token**
```typescript
test('expired token cleared automatically', async ({ page, context }) => {
  // Inject expired token
  await context.addInitScript(() => {
    const expiredToken = {
      access_token: 'expired',
      expires_at: Math.floor(Date.now() / 1000) - 3600
    };
    localStorage.setItem('sb-auth-token', JSON.stringify(expiredToken));
  });

  await page.goto('http://localhost:5173/login');

  // Should show login form (token cleared automatically)
  await expect(page.locator('input[type="email"]')).toBeVisible();

  // No console errors
  const errors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') errors.push(msg.text());
  });

  await page.waitForTimeout(1000);
  expect(errors.filter(e => e.includes('Invalid Refresh Token'))).toHaveLength(0);
});
```

**Scenario 3: Valid Session Auto-Redirect**
```typescript
test('valid session redirects to dashboard', async ({ page }) => {
  // Login first
  await page.goto('http://localhost:5173/login');
  await page.fill('input[type="email"]', 'test@rotary.org');
  await page.fill('input[type="password"]', 'password123');
  await page.click('button[type="submit"]');
  await page.waitForURL('**/dashboard');

  // Visit login page again
  await page.goto('http://localhost:5173/login');

  // Should auto-redirect to dashboard
  await page.waitForURL('**/dashboard');
});
```

---

## Production Monitoring

### Key Metrics

1. **Login Page Load Time**
   - Target: p95 < 500ms
   - Alert: p95 > 1000ms for 5 minutes

2. **Auth Check Duration**
   - Target: p95 < 300ms
   - Alert: p95 > 1000ms for 5 minutes

3. **Failed Auth Rate**
   - Target: < 5%
   - Alert: > 10% for 5 minutes

4. **Token Refresh Errors**
   - Target: 0 (with validated storage)
   - Alert: > 10 per hour

### Implementation (Sentry Example)

```typescript
// Track auth check performance
const transaction = Sentry.startTransaction({
  op: 'auth.check',
  name: 'Authentication Check'
});

try {
  await supabase.auth.getSession();
  transaction.setStatus('ok');
} catch (error) {
  transaction.setStatus('error');
  Sentry.captureException(error, {
    tags: {
      auth_phase: 'session_check',
      route: location.pathname
    }
  });
} finally {
  transaction.finish();
}
```

---

## Sample Code: Complete Auth Setup

### 1. Supabase Client with Validated Storage

**File**: `src/lib/supabase.ts`

```typescript
import { createClient } from '@supabase/supabase-js';

// Custom storage validates tokens before Supabase reads them
const validatedStorage = {
  getItem: (key: string) => {
    const item = localStorage.getItem(key);
    if (!item) return null;

    // Validate auth tokens
    if (key.includes('supabase.auth.token')) {
      try {
        const data = JSON.parse(item);
        const expiresAt = data.expires_at * 1000;
        const now = Date.now();
        const buffer = 60 * 1000; // 1 minute

        if (expiresAt < now + buffer) {
          console.log('[Storage] Expired token removed');
          localStorage.removeItem(key);
          return null;
        }
      } catch {
        console.error('[Storage] Invalid token format');
        localStorage.removeItem(key);
        return null;
      }
    }

    return item;
  },
  setItem: (key: string, value: string) => {
    localStorage.setItem(key, value);
  },
  removeItem: (key: string) => {
    localStorage.removeItem(key);
  },
};

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
  {
    auth: {
      storage: validatedStorage,
      autoRefreshToken: true,
      persistSession: true,
    },
  }
);
```

### 2. Auth State Machine

**File**: `src/contexts/AuthContext.tsx`

```typescript
import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User } from '@supabase/supabase-js';
import { supabase } from '@/lib/supabase';

type AuthState =
  | { status: 'initial' }
  | { status: 'checking' }
  | { status: 'authenticated'; user: User }
  | { status: 'guest' };

interface AuthContextValue {
  authState: AuthState;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [authState, setAuthState] = useState<AuthState>({ status: 'initial' });

  useEffect(() => {
    console.log('[Auth] Checking session');
    setAuthState({ status: 'checking' });

    supabase.auth.getSession().then(({ data: { session }, error }) => {
      if (error) {
        console.error('[Auth] Session error:', error);
        setAuthState({ status: 'guest' });
        return;
      }

      if (session) {
        console.log('[Auth] Session found:', session.user.id);
        setAuthState({ status: 'authenticated', user: session.user });
      } else {
        console.log('[Auth] No session');
        setAuthState({ status: 'guest' });
      }
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        console.log('[Auth] State change:', event);

        if (session) {
          setAuthState({ status: 'authenticated', user: session.user });
        } else {
          setAuthState({ status: 'guest' });
        }
      }
    );

    return () => subscription.unsubscribe();
  }, []);

  const login = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
  };

  const logout = async () => {
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ authState, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### 3. Route Guard

**File**: `src/components/guards/AuthGuard.tsx`

```typescript
import { ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

interface AuthGuardProps {
  children: ReactNode;
}

export const AuthGuard = ({ children }: AuthGuardProps) => {
  const { authState } = useAuth();
  const location = useLocation();

  // Synchronous public route check
  const publicRoutes = ['/login', '/signup', '/forgot-password'];
  const isPublicRoute = publicRoutes.some(route =>
    location.pathname.startsWith(route)
  );

  console.log('[AuthGuard] Route check:', {
    pathname: location.pathname,
    isPublicRoute,
    authStatus: authState.status
  });

  // Public routes render immediately
  if (isPublicRoute) {
    return <>{children}</>;
  }

  // Show loading for protected routes while checking
  if (authState.status === 'initial' || authState.status === 'checking') {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600" />
      </div>
    );
  }

  // Redirect to login if not authenticated
  if (authState.status === 'guest') {
    return <Navigate to="/login" replace />;
  }

  // Render protected content
  return <>{children}</>;
};
```

### 4. Login Page

**File**: `src/components/auth/LoginPage.tsx`

```typescript
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

export const LoginPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      await login(email, password);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Login failed');
      console.error('[Login] Error:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8 p-8">
        <h2 className="text-3xl font-bold text-center">
          Georgetown Rotary Club
        </h2>
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          {error && (
            <div className="rounded-md bg-red-50 p-4">
              <p className="text-sm text-red-800">{error}</p>
            </div>
          )}
          <div className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium">
                Email
              </label>
              <input
                id="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-1 block w-full px-3 py-2 border rounded-md"
              />
            </div>
            <div>
              <label htmlFor="password" className="block text-sm font-medium">
                Password
              </label>
              <input
                id="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="mt-1 block w-full px-3 py-2 border rounded-md"
              />
            </div>
          </div>
          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 px-4 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
          >
            {loading ? 'Signing in...' : 'Sign in'}
          </button>
        </form>
      </div>
    </div>
  );
};
```

---

## Summary: The Five Critical Rules

1. **Synchronous Routing**: Never use `useEffect` to determine what UI to render
2. **Boundary Validation**: Validate tokens at storage layer, before consumption
3. **State Machines**: Define valid auth states and transitions upfront
4. **Direct Client Usage**: Public pages use Supabase directly (no framework hooks)
5. **Logging First**: Add comprehensive logging BEFORE building features

---

## Next Steps for CTO

1. **Create new Rotary Club repo** with Vite + React + TypeScript
2. **Implement auth foundation** (Phase 1 from checklist)
   - Supabase client with validated storage
   - Auth state machine
   - Comprehensive logging
3. **Build public routes** (Phase 2 from checklist)
   - Login, Signup, Forgot Password pages
   - Direct Supabase usage (no framework hooks)
4. **Add AuthGuard** for protected routes
5. **Write tests** (Phase 3 from checklist)
   - Fresh browser → login form
   - Expired token → auto-cleanup
   - Valid session → auto-redirect

**Estimated Time**: 2-3 hours to implement bulletproof auth (vs 3+ hours debugging later)

---

## ADDENDUM: WebAuthn Passkey Implementation (2025-12-08)

**Context**: Successfully deployed WebAuthn passkey authentication for Brandmine Hub. This is the **recommended approach** for Rotary Club app if you want world-class security and the best mobile/PWA experience.

### Why WebAuthn Instead of Password Auth

**Security**: 99%+ phishing resistance vs 20-50% for password+SMS OTP
**UX**: 3-second biometric sign-in vs 2-minute magic link flow
**PWA Perfect**: No iOS session isolation issues (auth happens in-app)
**2025 Standard**: Industry best practice (Apple, Google, Microsoft all using passkeys)

### Implementation Guide

Full production-verified implementation documented in:
- [WebAuthn Production Deployment](../dev-journal/2025-12-08-webauthn-production-deployment.md)
- [WebAuthn Lessons Learned](../dev-journal/2025-12-08-webauthn-lessons-learned.md)
- [Binary Data Reference](../dev-journal/2025-12-08-webauthn-supabase-binary-data-reference.md)
- [ADR-0030: WebAuthn Passkeys](../adr/0030-webauthn-passkeys-primary-authentication.md)

### Critical Technical Requirements

#### 1. Binary Data Handling (COSE Public Keys)

**Problem**: Supabase-js JSON-serializes Uint8Array, breaking cryptographic verification.

**Solution**: Use PostgreSQL hex format.

```typescript
// Registration: Store public key as hex
function uint8ArrayToHex(bytes: Uint8Array): string {
  return '\\x' + Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

const publicKeyHex = uint8ArrayToHex(credentialInfo.publicKey);
await supabase.from('passkey_credentials').insert({
  public_key: publicKeyHex  // PostgreSQL interprets \x as bytea
});

// Authentication: Convert hex back to Uint8Array
function ensureUint8Array(hexString: string): Uint8Array {
  const clean = hexString.replace(/^\\x/, '');
  const bytes = clean.match(/.{1,2}/g);
  return new Uint8Array(bytes.map(byte => parseInt(byte, 16)));
}

const publicKey = ensureUint8Array(storedCred.public_key);
```

**Source**: [Supabase Discussion #2441](https://github.com/orgs/supabase/discussions/2441)

#### 2. Session Creation (No Direct Admin API)

**Problem**: Supabase v2 has no `admin.createSession()` method.

**Solution**: Use `generateLink()` + `verifyOtp()` pattern.

```typescript
// Edge Function: After WebAuthn verification succeeds
const { data: linkData } = await supabaseAdmin.auth.admin.generateLink({
  type: 'magiclink',
  email: user.email,
});

const { data: sessionData } = await supabaseAdmin.auth.verifyOtp({
  token_hash: linkData.properties.hashed_token,
  type: 'email',
});

// Return tokens to client
return {
  verified: true,
  accessToken: sessionData.session.access_token,
  refreshToken: sessionData.session.refresh_token,
};
```

**Important**: This is NOT a magic link authentication flow. No email is sent. The hashed token is generated and verified server-side only. User sees biometric prompt, not email.

**Source**: [Supabase Discussion #11854](https://github.com/orgs/supabase/discussions/11854)

#### 3. Database Schema

```sql
CREATE TABLE passkey_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  credential_id TEXT NOT NULL UNIQUE,  -- Base64url string (SimpleWebAuthn v13)
  public_key BYTEA NOT NULL,           -- COSE format, stored as hex
  counter BIGINT NOT NULL DEFAULT 0,   -- Increments each auth
  transports TEXT[],                   -- ['internal', 'usb', 'nfc', 'ble']
  device_name TEXT,                    -- Optional: "Randal's iPhone"
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_used_at TIMESTAMPTZ,
  CONSTRAINT unique_credential_per_user UNIQUE (user_id, credential_id)
);

CREATE INDEX idx_passkey_credentials_user_id ON passkey_credentials(user_id);
CREATE INDEX idx_passkey_credentials_credential_id ON passkey_credentials(credential_id);

-- Challenge table (5-minute expiration)
CREATE TABLE passkey_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  challenge TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_passkey_challenges_user_id ON passkey_challenges(user_id);
```

#### 4. Edge Functions Architecture

**Four Edge Functions Required**:

1. **webauthn-register-options** - Generate registration challenge
2. **webauthn-register-verify** - Verify registration and store credential
3. **webauthn-auth-options** - Generate authentication challenge
4. **webauthn-auth-verify** - Verify authentication and create session

**Key Libraries**:
- `@simplewebauthn/server@13.0.0` (server-side verification)
- `@simplewebauthn/browser@10+` (client-side WebAuthn API)

**Deno Import Pattern**:
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { verifyAuthenticationResponse } from 'https://esm.sh/@simplewebauthn/server@13.0.0'
```

#### 5. Frontend Implementation

```typescript
import { startRegistration, startAuthentication } from '@simplewebauthn/browser';

// Registration Flow
const handlePasskeyRegister = async () => {
  // Step 1: Get registration options from Edge Function
  const { data: options } = await supabase.functions.invoke(
    'webauthn-register-options',
    { body: { email } }
  );

  // Step 2: Trigger device biometric enrollment
  const credential = await startRegistration(options.options);

  // Step 3: Verify and store credential
  const { data } = await supabase.functions.invoke(
    'webauthn-register-verify',
    {
      body: {
        userId: options.userId,
        credential,
        deviceName: `${navigator.platform} - ${new Date().toLocaleDateString()}`
      }
    }
  );
};

// Authentication Flow
const handlePasskeyAuth = async () => {
  // Step 1: Get authentication options
  const { data: options } = await supabase.functions.invoke(
    'webauthn-auth-options',
    { body: { email } }
  );

  // Step 2: Trigger device biometric prompt
  const credential = await startAuthentication(options.options);

  // Step 3: Verify and get session
  const { data } = await supabase.functions.invoke(
    'webauthn-auth-verify',
    { body: { userId: options.userId, credential } }
  );

  // Step 4: Set session in Supabase client
  await supabase.auth.setSession({
    access_token: data.accessToken,
    refresh_token: data.refreshToken,
  });

  // Step 5: Redirect to dashboard
  window.location.href = '/dashboard';
};
```

### Critical Gotchas (Lessons Learned)

1. **credential.id is base64url string in v13** - Don't decode it!
2. **publicKey MUST be Uint8Array** - Hex string causes CBOR errors
3. **Use hex format for storage** - Direct Uint8Array gets JSON-serialized
4. **Challenges are one-time use** - Delete after verification
5. **Counter must increment** - Update after each authentication
6. **Origin validation is critical** - Must match domain exactly
7. **SimpleWebAuthn versions must align** - Browser and server libraries

### Performance Metrics (Production Verified)

- **Registration**: ~10 seconds (one-time enrollment)
- **Authentication**: ~3 seconds (biometric → dashboard)
- **Edge Function Latency**: 150-200ms per invocation
- **Session Creation**: Server-side, no email delay

### Comparison: WebAuthn vs Password Auth

| Metric | Password Auth | WebAuthn Passkeys |
|--------|--------------|-------------------|
| Security | 60-80% phishing resistance | 99%+ phishing resistance |
| Login Time | 30-60 seconds | 3 seconds |
| iOS PWA Issues | Session isolation (Safari ≠ PWA) | None (auth in-app) |
| Email Dependency | Yes (magic links) | No |
| Offline Support | No (needs email) | Yes (after enrollment) |
| User Experience | Multi-step (email → link → click) | Single tap (biometric) |
| 2025 Best Practice | Legacy | Industry standard |

### Recommendation for Rotary Club App

**Use WebAuthn** if:
- ✅ App will be used as PWA on mobile devices
- ✅ Users have modern devices (iPhone 8+, Android 9+)
- ✅ Small team (easy to onboard with demos)
- ✅ Want world-class security from day one

**Use Password Auth** if:
- ⚠️ Users have old devices (pre-2018)
- ⚠️ Need public signup (can't demo each user)
- ⚠️ Time-constrained (WebAuthn is 2-3 days vs 4 hours for password)

### Implementation Estimate

**Full WebAuthn Setup**:
- Database schema: 30 minutes
- Edge Functions (4 functions): 4 hours
- Frontend components: 2 hours
- Testing: 2 hours
- **Total**: ~9 hours

**Recommended**: Start with password auth (use code from this briefing), add WebAuthn in Phase 2 after core features are stable.

### Reference Implementation

All code is production-verified and available in:
- `hub/supabase/functions/webauthn-*` (Edge Functions)
- `hub/src/components/atomic-crm/login/PasskeyLoginPage.tsx` (Frontend)
- Database schema in production (wcfhbzbmxztdzwjaujoq project)

### Additional Resources

- [SimpleWebAuthn Documentation](https://simplewebauthn.dev/)
- [WebAuthn Guide](https://webauthn.guide/)
- [Passkeys vs OTP 2025](https://www.iddataweb.com/passkeys-vs-otp-2025/)
- [iOS PWA Magic Link Limitations](https://intercom.help/progressier/en/articles/10433517-can-you-use-magic-links-in-a-pwa)

---

**Last Updated**: 2025-12-08
**Status**: Ready for implementation - choose password OR WebAuthn based on requirements
**Priority**: CRITICAL - Auth is foundation, must be correct from day one
**Questions**: Contact CEO (Randal) for clarification on Rotary Club app requirements
