// src/app/features/dashboard/dashboard.component.ts
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AdminService, DashboardSummary } from '../../core/services/admin.service';
import { ThemeService } from '../../core/services/theme.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <div class="space-y-8">
      <!-- Encabezado -->
      <div class="flex items-center justify-between flex-wrap gap-3">
        <h1 class="text-3xl font-extrabold bg-gradient-to-r from-primary-600 to-blue-500 bg-clip-text text-transparent">
          Panel de Control
        </h1>
        <span class="text-sm text-gray-500 dark:text-gray-400">Actualizado: {{ summary ? (summary.updated_at || 'Hoy') : '---' }}</span>
      </div>

      <!-- Tarjetas de estadísticas -->
      <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <!-- Tarjeta genérica -->
        <div
          class="group relative overflow-hidden rounded-2xl bg-white dark:bg-gray-900 shadow-md border border-gray-100 dark:border-gray-700 p-6 transition-all duration-300 hover:shadow-xl hover:-translate-y-1"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Usuarios Totales</p>
              <p class="mt-1 text-4xl font-bold text-gray-900 dark:text-white">
                {{ summary?.total_users || 0 }}
              </p>
            </div>
            <div
              class="rounded-xl bg-gradient-to-br from-primary-500 to-blue-500 p-3 text-white shadow-lg group-hover:scale-110 transition-transform duration-300"
            >
              <svg class="h-7 w-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                ></path>
              </svg>
            </div>
          </div>
          <div class="mt-4 flex justify-between text-sm">
            <span class="text-green-600 dark:text-green-400 font-medium">{{ summary?.active_users || 0 }} activos</span>
            <span class="text-red-600 dark:text-red-400 font-medium">{{ summary?.inactive_users || 0 }} inactivos</span>
          </div>
        </div>

        <!-- Roles -->
        <div
          class="group relative overflow-hidden rounded-2xl bg-white dark:bg-gray-900 shadow-md border border-gray-100 dark:border-gray-700 p-6 transition-all duration-300 hover:shadow-xl hover:-translate-y-1"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Roles</p>
              <p class="mt-1 text-4xl font-bold text-gray-900 dark:text-white">
                {{ summary?.total_roles || 0 }}
              </p>
            </div>
            <div
              class="rounded-xl bg-gradient-to-br from-blue-500 to-indigo-500 p-3 text-white shadow-lg group-hover:scale-110 transition-transform duration-300"
            >
              <svg class="h-7 w-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                ></path>
              </svg>
            </div>
          </div>
          <div class="mt-4">
            <a
              routerLink="/admin/roles"
              class="text-sm font-semibold text-primary-600 dark:text-primary-400 hover:underline"
            >
              Ver todos los roles →
            </a>
          </div>
        </div>

        <!-- Permisos -->
        <div
          class="group relative overflow-hidden rounded-2xl bg-white dark:bg-gray-900 shadow-md border border-gray-100 dark:border-gray-700 p-6 transition-all duration-300 hover:shadow-xl hover:-translate-y-1"
        >
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Permisos</p>
              <p class="mt-1 text-4xl font-bold text-gray-900 dark:text-white">
                {{ summary?.total_permissions || 0 }}
              </p>
            </div>
            <div
              class="rounded-xl bg-gradient-to-br from-purple-500 to-fuchsia-500 p-3 text-white shadow-lg group-hover:scale-110 transition-transform duration-300"
            >
              <svg class="h-7 w-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"
                ></path>
              </svg>
            </div>
          </div>
          <div class="mt-4">
            <a
              routerLink="/admin/permissions"
              class="text-sm font-semibold text-primary-600 dark:text-primary-400 hover:underline"
            >
              Ver todos los permisos →
            </a>
          </div>
        </div>

        <!-- Acciones rápidas -->
        <div
          class="rounded-2xl bg-gradient-to-br from-primary-600 to-blue-600 p-6 shadow-lg text-white transition-transform duration-300 hover:scale-[1.02]"
        >
          <p class="text-sm font-medium opacity-90">Acciones Rápidas</p>
          <div class="mt-5 space-y-3">
            <a
              routerLink="/admin/users/create"
              class="block w-full rounded-lg bg-white/20 hover:bg-white/30 backdrop-blur-md px-4 py-2 text-center text-sm font-semibold transition-colors duration-200"
            >
              ➕ Nuevo Usuario
            </a>
            <a
              routerLink="/admin/roles/create"
              class="block w-full rounded-lg bg-white text-primary-700 hover:bg-gray-100 px-4 py-2 text-center text-sm font-semibold transition-colors duration-200"
            >
              🧩 Nuevo Rol
            </a>
          </div>
        </div>
      </div>

      <!-- Usuarios por rol -->
      <div class="rounded-2xl bg-white dark:bg-gray-900 p-6 shadow-md border border-gray-100 dark:border-gray-700">
        <h2 class="text-lg font-semibold text-gray-800 dark:text-white mb-4 flex items-center gap-2">
          <svg class="w-5 h-5 text-primary-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5V9H2v11h5m10 0v2m-6-2v2"></path>
          </svg>
          Usuarios por Rol
        </h2>

        @if (loading) {
          <div class="flex justify-center items-center p-6">
            <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-primary-500 border-t-transparent"></div>
            <span class="ml-3 text-gray-600 dark:text-gray-300">Cargando datos...</span>
          </div>
        } @else if (summary?.users_by_role?.length) {
          <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            @for (roleData of summary?.users_by_role; track roleData.role) {
              <div
                class="rounded-xl bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-700 border border-gray-200 dark:border-gray-600 p-4 flex items-center justify-between transition-all duration-200 hover:shadow-md"
              >
                <span class="text-sm font-semibold text-gray-800 dark:text-gray-200">{{ roleData.role }}</span>
                <span
                  class="rounded-full bg-primary-100 dark:bg-primary-900/50 px-3 py-0.5 text-xs font-medium text-primary-800 dark:text-primary-300"
                  >{{ roleData.count }} usuarios</span
                >
              </div>
            }
          </div>
        } @else {
          <p class="text-gray-500 dark:text-gray-400 text-sm italic">No hay datos disponibles.</p>
        }
      </div>

      <!-- Usuarios recientes -->
      <div class="rounded-2xl bg-white dark:bg-gray-900 p-6 shadow-md border border-gray-100 dark:border-gray-700">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-semibold text-gray-800 dark:text-white flex items-center gap-2">
            <svg class="w-5 h-5 text-primary-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5V9H2v11h5m10 0v2m-6-2v2"></path>
            </svg>
            Usuarios Recientes
          </h2>
          <a
            routerLink="/admin/users"
            class="text-sm font-semibold text-primary-600 dark:text-primary-400 hover:underline"
            >Ver todos →</a
          >
        </div>

        @if (loading) {
          <div class="flex justify-center items-center p-6">
            <div class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-primary-500 border-t-transparent"></div>
            <span class="ml-3 text-gray-600 dark:text-gray-300">Cargando usuarios...</span>
          </div>
        } @else if (summary?.recent_users?.length) {
          <div class="overflow-x-auto rounded-xl border border-gray-200 dark:border-gray-700">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
              <thead class="bg-gray-100 dark:bg-gray-800">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Nombre</th>
                  <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Email</th>
                  <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Roles</th>
                  <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Fecha</th>
                  <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase">Acciones</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
                @for (user of summary?.recent_users; track user.id) {
                  <tr class="hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                    <td class="px-6 py-4 whitespace-nowrap flex items-center gap-3">
                      <div class="h-9 w-9 rounded-full bg-primary-100 dark:bg-primary-900/50 flex items-center justify-center">
                        <span class="text-primary-700 dark:text-primary-300 font-semibold">{{ getUserInitials(user) }}</span>
                      </div>
                      <span class="font-medium text-gray-800 dark:text-white">{{ user.name }}</span>
                    </td>
                    <td class="px-6 py-4 text-gray-700 dark:text-gray-300">{{ user.email }}</td>
                    <td class="px-6 py-4">
                      <div class="flex flex-wrap gap-1">
                        @for (role of user.roles; track role.id) {
                          <span
                            class="inline-flex items-center rounded-full bg-blue-100 dark:bg-blue-900/50 px-2.5 py-0.5 text-xs font-medium text-blue-800 dark:text-blue-300"
                          >
                            {{ role.name }}
                          </span>
                        }
                      </div>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500 dark:text-gray-400">
                      {{ formatDate(user.created_at) }}
                    </td>
                    <td class="px-6 py-4 text-right">
                      <a
                        [routerLink]="['/admin/users/edit', user.id]"
                        class="text-primary-600 dark:text-primary-400 hover:text-primary-800 dark:hover:text-primary-200"
                        title="Editar"
                      >
                        <svg class="h-5 w-5 inline-block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                      </a>
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        } @else {
          <p class="text-gray-500 dark:text-gray-400 text-sm italic">No hay usuarios recientes.</p>
        }
      </div>
    </div>
  `,
})
export class DashboardComponent implements OnInit {
  private adminService = inject(AdminService);
  private themeService = inject(ThemeService);

  summary: DashboardSummary | null = null;
  loading = true;

  ngOnInit() {
    this.loadDashboardData();
  }

  loadDashboardData() {
    this.loading = true;
    this.adminService.getDashboardSummary().subscribe({
      next: (data) => {
        this.summary = data;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error al cargar datos del dashboard:', error);
        this.loading = false;
      },
    });
  }

  getUserInitials(user: any): string {
    if (!user || !user.name) return '';
    const nameParts = user.name.split(' ');
    if (nameParts.length === 1) return nameParts[0].charAt(0).toUpperCase();
    return (nameParts[0].charAt(0) + nameParts[1].charAt(0)).toUpperCase();
  }

  formatDate(dateString?: string): string {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString();
  }
}
