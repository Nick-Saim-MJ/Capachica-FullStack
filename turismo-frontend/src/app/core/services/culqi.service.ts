import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, from, throwError } from 'rxjs';
import { map, switchMap, catchError } from 'rxjs/operators';
import { environment } from '../../../environments/environments';

// Declarar el objeto global Culqi
declare var Culqi: any;

export interface CulqiConfig {
  public_key: string;
  currency: string;
  environment: string;
}

export interface ProcesarPagoRequest {
  reserva_id: number;
  token: string;
  email: string;
  installments?: number;
}

export interface ProcesarPagoResponse {
  success: boolean;
  message: string;
  data?: {
    reserva: any;
    pago: {
      id: number;
      charge_id: string;
      monto: number;
      moneda: string;
      estado: string;
      referencia: string | null;
      fecha: string;
    };
  };
  error?: string;
}

@Injectable({
  providedIn: 'root'
})
export class CulqiService {
  private http = inject(HttpClient);
  private readonly API_URL = `${environment.apiUrl}/pagos/culqi`;
  private culqiConfig: CulqiConfig | null = null;
  private culqiLoaded = false;

  /**
   * Obtener la configuración pública de Culqi
   */
  obtenerConfiguracion(): Observable<CulqiConfig> {
    return this.http.get<{ success: boolean; data: CulqiConfig }>(`${this.API_URL}/config`)
      .pipe(
        map(response => {
          this.culqiConfig = response.data;
          return response.data;
        })
      );
  }

  /**
   * Cargar el script de Culqi Checkout v4
   */
  cargarCulqiScript(): Promise<void> {
    return new Promise((resolve, reject) => {
      // Si ya está cargado, resolver inmediatamente
      if (this.culqiLoaded && typeof Culqi !== 'undefined') {
        resolve();
        return;
      }

      // Verificar si el script ya existe
      const scriptExistente = document.getElementById('culqi-checkout');
      if (scriptExistente) {
        scriptExistente.remove();
      }

      // Crear y cargar el script
      const script = document.createElement('script');
      script.id = 'culqi-checkout';
      script.src = 'https://checkout.culqi.com/js/v4';
      script.async = true;

      script.onload = () => {
        console.log('✅ Culqi script cargado exitosamente');
        this.culqiLoaded = true;
        resolve();
      };

      script.onerror = (error) => {
        console.error('❌ Error al cargar script de Culqi:', error);
        this.culqiLoaded = false;
        reject(new Error('No se pudo cargar el script de Culqi'));
      };

      document.head.appendChild(script);
    });
  }

  /**
   * Abrir el formulario de pago de Culqi
   */
  async abrirFormularioPago(
    monto: number,
    descripcion: string,
    email: string,
    options?: {
      cuotas?: number;
      logoUrl?: string;
      nombreEmpresa?: string;
    }
  ): Promise<string> {
    try {
      // Cargar configuración si no existe
      if (!this.culqiConfig) {
        const config = await this.obtenerConfiguracion().toPromise();
        if (!config) {
          throw new Error('No se pudo obtener la configuración de Culqi');
        }
        this.culqiConfig = config;
      }

      // Validar que tenemos la clave pública
      if (!this.culqiConfig?.public_key) {
        throw new Error('No se ha configurado la clave pública de Culqi. Por favor contacte al administrador.');
      }

      // Cargar script si no está cargado
      if (!this.culqiLoaded) {
        await this.cargarCulqiScript();
      }

      // Verificar que Culqi esté disponible
      if (typeof Culqi === 'undefined') {
        throw new Error('Culqi no está disponible. Verifique la conexión a internet.');
      }

      // Convertir monto a céntimos (Culqi requiere el monto en céntimos)
      const montoCentimos = Math.round(monto * 100);

      console.log('🔑 Configurando Culqi con public key:', this.culqiConfig?.public_key);
      console.log('💰 Monto en céntimos:', montoCentimos);

      return new Promise((resolve, reject) => {
        // Configurar Culqi
        Culqi.publicKey = this.culqiConfig!.public_key;
        
        // Opciones del checkout
        // NOTA: Yape solo funciona en producción (credenciales live)
        // En ambiente test solo está disponible pago con tarjeta
       // const isProduction = this.culqiConfig!.environment === 'live';
        
        Culqi.options = {
          lang: 'es',
          installments: options?.cuotas || false,
          paymentMethods: {
            tarjeta: true,
            yape: true, // Solo en producción
            billetera: true, // Solo en producción
            bancaMovil: true, // Solo en producción
            agente: false,
            cuotealo: false
          },
          style: {
            logo: options?.logoUrl || '',
            maincolor: '#FF6B35',
            buttontext: '#FFFFFF',
            maintext: '#4A4A4A',
            desctext: '#7A7A7A'
          }
        };

        // Settings (información de la transacción)
        Culqi.settings({
          title: options?.nombreEmpresa || 'Turismo Capachica',
          currency: this.culqiConfig!.currency || 'PEN',
          description: descripcion,
          amount: montoCentimos
        });

        // Callback cuando se crea el token exitosamente
        Culqi.options.closeCallback = () => {
          console.log('⚠️ Usuario cerró el formulario de pago');
          reject(new Error('Pago cancelado por el usuario'));
        };

        // Función global para manejar la respuesta
        (window as any).culqiResponseHandler = () => {
          if (Culqi.token) {
            console.log('✅ Token de Culqi generado:', Culqi.token.id);
            resolve(Culqi.token.id);
          } else if (Culqi.error) {
            console.error('❌ Error de Culqi:', Culqi.error);
            reject(new Error(Culqi.error.user_message || 'Error al procesar el pago'));
          }
        };

        // Abrir el checkout
        console.log('🚀 Abriendo checkout de Culqi...');
        Culqi.open();
      });

    } catch (error: any) {
      console.error('❌ Error en abrirFormularioPago:', error);
      throw error;
    }
  }

  /**
   * Procesar el pago en el backend
   */
  procesarPago(datos: ProcesarPagoRequest): Observable<ProcesarPagoResponse> {
    return this.http.post<ProcesarPagoResponse>(`${this.API_URL}/procesar`, datos);
  }

  /**
   * Flujo completo de pago
   */
  realizarPagoCompleto(
    reservaId: number,
    monto: number,
    email: string,
    descripcion: string,
    options?: {
      cuotas?: number;
      logoUrl?: string;
      nombreEmpresa?: string;
    }
  ): Observable<ProcesarPagoResponse> {
    return from(
      this.abrirFormularioPago(monto, descripcion, email, options)
    ).pipe(
      switchMap(token => {
        const datosPago: ProcesarPagoRequest = {
          reserva_id: reservaId,
          token: token,
          email: email,
          installments: options?.cuotas || 0
        };
        return this.procesarPago(datosPago);
      }),
      catchError(error => {
        console.error('Error en el flujo de pago:', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Validar si Culqi está disponible
   */
  isCulqiDisponible(): boolean {
    return this.culqiLoaded && typeof Culqi !== 'undefined';
  }

  /**
   * Obtener configuración actual
   */
  getConfig(): CulqiConfig | null {
    return this.culqiConfig;
  }
}
