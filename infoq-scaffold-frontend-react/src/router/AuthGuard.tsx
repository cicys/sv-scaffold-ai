import { type ReactElement, useEffect, useState } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { Spin } from 'antd';
import { getToken } from '@/utils/auth';
import { isWhiteListRoute } from '@/router/public-routes';
import { useUserStore } from '@/store/modules/user';
import { usePermissionStore } from '@/store/modules/permission';

type AuthGuardProps = {
  children: ReactElement;
};

export default function AuthGuard({ children }: AuthGuardProps) {
  const location = useLocation();
  const [loading, setLoading] = useState(true);
  const token = getToken();
  const roles = useUserStore((state) => state.roles);

  useEffect(() => {
    let disposed = false;

    const bootstrap = async () => {
      if (!token) {
        if (!disposed) {
          setLoading(false);
        }
        return;
      }

      try {
        if (!roles || roles.length === 0) {
          await useUserStore.getState().getInfo();
          await usePermissionStore.getState().generateRoutes();
        }
      } finally {
        if (!disposed) {
          setLoading(false);
        }
      }
    };

    bootstrap();
    return () => {
      disposed = true;
    };
  }, [token, roles]);

  if (!token) {
    if (isWhiteListRoute(location.pathname)) {
      return children;
    }
    return <Navigate to={`/login?redirect=${encodeURIComponent(location.pathname + location.search)}`} replace />;
  }

  if (loading) {
    return <Spin />;
  }

  return children;
}
