import NativeEkeySdk from './NativeEkeySdk';

export type EkeyLoginStatus = 'completed' | 'cancelled' | 'failed';

export type EkeyLoginResult = {
  status: EkeyLoginStatus;
  redirectUri?: string;
  error?: string;
};

/**
 * Starts the eKey 2.0 app-to-app login flow. All integration config lives in the native
 * EkeySDK (iOS) / ekeysdk (Android) modules — nothing to configure here.
 */
export function initiateEkeyLogin(): Promise<EkeyLoginResult> {
  return NativeEkeySdk.initiateLogin() as Promise<EkeyLoginResult>;
}
