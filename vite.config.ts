import vue from '@vitejs/plugin-vue'
import laravel from 'laravel-vite-plugin'
import path from 'path'
import tailwindcss from '@tailwindcss/vite'
import vuetify from 'vite-plugin-vuetify'
import { defineConfig } from 'vite'

export default defineConfig({

    // uncomment this block when running with docker
    server: {
        hmr: {
            host: 'localhost',
        },
        port: 5173,
        host: true,
    },

    plugins: [
        laravel({
            input: ['resources/js/app.ts'],
            ssr: 'resources/js/ssr.ts',
            refresh: false,
        }),
        tailwindcss(),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
        vuetify({
            autoImport: true ,
            styles: {
                configFile: 'resources/scss/settings.scss'
            },
        }),
    ],
    resolve: {
        alias: {
            '@': path.resolve(__dirname, './resources/js'),
        },
    },
})
