/*
 * Copyright (C) 2020 Linux Studio Plugins Project <https://lsp-plug.in/>
 *           (C) 2020 Vladimir Sadovnikov <sadko4u@gmail.com>
 *
 * This file is part of lsp-r3d-base-lib
 * Created on: 24 апр. 2019 г.
 *
 * lsp-r3d-base-lib is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * lsp-r3d-base-lib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with lsp-r3d-base-lib. If not, see <https://www.gnu.org/licenses/>.
 */

#include <lsp-plug.in/common/types.h>
#include <lsp-plug.in/r3d/base/backend.h>
#include <lsp-plug.in/stdlib/string.h>

namespace lsp
{
    namespace r3d
    {
        void base_backend_t::construct()
        {
            viewLeft    = 0;
            viewTop     = 0;
            viewWidth   = 0;
            viewHeight  = 0;

            // Initialize vtable
            #define R3D_BASE_BACKEND_EXP(func)   backend_t::func = base_backend_t::func;
            R3D_BASE_BACKEND_EXP(destroy);
            R3D_BASE_BACKEND_EXP(locate);
            R3D_BASE_BACKEND_EXP(set_matrix);
            R3D_BASE_BACKEND_EXP(get_matrix);
            R3D_BASE_BACKEND_EXP(get_location);
            R3D_BASE_BACKEND_EXP(get_bg_color);
            R3D_BASE_BACKEND_EXP(set_bg_color);
            #undef R3D_BASE_BACKEND_EXP
        }

        base_backend_t::base_backend_t()
        {
            construct();
        }

        void base_backend_t::init_matrix_identity(mat4_t *m)
        {
            ::bzero(m, sizeof(mat4_t));
            m->m[0]     = 1.0f;
            m->m[5]     = 1.0f;
            m->m[10]    = 1.0f;
            m->m[15]    = 1.0f;
        }

        status_t base_backend_t::init(backend_t *handle)
        {
            base_backend_t *_this = static_cast<base_backend_t *>(handle);

            _this->viewLeft         = 0;
            _this->viewTop          = 0;
            _this->viewWidth        = 1;
            _this->viewHeight       = 1;
            _this->colBackground.r  = 0.0f;
            _this->colBackground.g  = 0.0f;
            _this->colBackground.b  = 0.0f;
            _this->colBackground.a  = 1.0f;

            init_matrix_identity(&_this->matProjection);
            init_matrix_identity(&_this->matView);
            init_matrix_identity(&_this->matWorld);

            return STATUS_OK;
        }

        void base_backend_t::destroy(backend_t *handle)
        {
            // Free pointer to self
            ::free(handle);
        }

        status_t base_backend_t::set_matrix(backend_t *handle, matrix_type_t type, const mat4_t *m)
        {
            if (m == NULL)
                return STATUS_BAD_ARGUMENTS;

            base_backend_t *_this = static_cast<base_backend_t *>(handle);
            switch (type)
            {
                case MATRIX_PROJECTION: _this->matProjection    = *m;   break;
                case MATRIX_VIEW:       _this->matView          = *m;   break;
                case MATRIX_WORLD:      _this->matWorld         = *m;   break;
                default: return STATUS_INVALID_VALUE;
            }
            return STATUS_OK;
        }

        status_t base_backend_t::get_matrix(backend_t *handle, matrix_type_t type, mat4_t *m)
        {
            if (m == NULL)
                return STATUS_BAD_ARGUMENTS;

            base_backend_t *_this = static_cast<base_backend_t *>(handle);
            switch (type)
            {
                case MATRIX_PROJECTION: *m  = _this->matProjection;     break;
                case MATRIX_VIEW:       *m  = _this->matView;           break;
                case MATRIX_WORLD:      *m  = _this->matWorld;          break;
                default: return STATUS_INVALID_VALUE;
            }
            return STATUS_OK;
        }

        status_t base_backend_t::get_location(backend_t *handle, ssize_t *left, ssize_t *top, ssize_t *width, ssize_t *height)
        {
            base_backend_t *_this = static_cast<base_backend_t *>(handle);
            if (left != NULL)
                *left   = _this->viewLeft;
            if (top != NULL)
                *top    = _this->viewTop;
            if (width != NULL)
                *width  = _this->viewWidth;
            if (height != NULL)
                *height = _this->viewHeight;

            return STATUS_OK;
        }

        void base_backend_t::matrix_mul(mat4_t *r, const mat4_t *s, const mat4_t *m)
        {
            const float *A      = s->m;
            const float *B      = m->m;
            float *R            = r->m;

            R[0]    = A[0] * B[0]   + A[4] * B[1]   + A[8] * B[2]   + A[12] * B[3];
            R[1]    = A[1] * B[0]   + A[5] * B[1]   + A[9] * B[2]   + A[13] * B[3];
            R[2]    = A[2] * B[0]   + A[6] * B[1]   + A[10] * B[2]  + A[14] * B[3];
            R[3]    = A[3] * B[0]   + A[7] * B[1]   + A[11] * B[2]  + A[15] * B[3];

            R[4]    = A[0] * B[4]   + A[4] * B[5]   + A[8] * B[6]   + A[12] * B[7];
            R[5]    = A[1] * B[4]   + A[5] * B[5]   + A[9] * B[6]   + A[13] * B[7];
            R[6]    = A[2] * B[4]   + A[6] * B[5]   + A[10] * B[6]  + A[14] * B[7];
            R[7]    = A[3] * B[4]   + A[7] * B[5]   + A[11] * B[6]  + A[15] * B[7];

            R[8]    = A[0] * B[8]   + A[4] * B[9]   + A[8] * B[10]  + A[12] * B[11];
            R[9]    = A[1] * B[8]   + A[5] * B[9]   + A[9] * B[10]  + A[13] * B[11];
            R[10]   = A[2] * B[8]   + A[6] * B[9]   + A[10] * B[10] + A[14] * B[11];
            R[11]   = A[3] * B[8]   + A[7] * B[9]   + A[11] * B[10] + A[15] * B[11];

            R[12]   = A[0] * B[12]  + A[4] * B[13]  + A[8] * B[14]  + A[12] * B[15];
            R[13]   = A[1] * B[12]  + A[5] * B[13]  + A[9] * B[14]  + A[13] * B[15];
            R[14]   = A[2] * B[12]  + A[6] * B[13]  + A[10] * B[14] + A[14] * B[15];
            R[15]   = A[3] * B[12]  + A[7] * B[13]  + A[11] * B[14] + A[15] * B[15];
        }

        void base_backend_t::memswap(void *a, void *b, size_t bytes)
        {
        #ifdef ARCH_64BIT
            // 32-byte blocks
            uint64_t *xa    = reinterpret_cast<uint64_t *>(a);
            uint64_t *xb    = reinterpret_cast<uint64_t *>(b);

            for (; bytes >= 32 ; bytes -= 32, xa += 4, xb += 4)
            {
                uint64_t t0     = xa[0];
                uint64_t t1     = xa[1];
                uint64_t t2     = xa[2];
                uint64_t t3     = xa[3];

                xa[0]           = xb[0];
                xa[1]           = xb[1];
                xa[2]           = xb[2];
                xa[3]           = xb[3];

                xb[0]           = t0;
                xb[1]           = t1;
                xb[2]           = t2;
                xb[3]           = t3;
            }

            // 4-byte blocks
            uint32_t *ya    = reinterpret_cast<uint32_t *>(xa);
            uint32_t *yb    = reinterpret_cast<uint32_t *>(xb);

            for (; bytes >= 4 ; bytes -= 4, ++ya, ++yb)
            {
                uint32_t t0     = ya[0];
                ya[0]           = yb[0];
                yb[0]           = t0;
            }

            // 1-byte blocks
            uint8_t *za    = reinterpret_cast<uint8_t *>(ya);
            uint8_t *zb    = reinterpret_cast<uint8_t *>(yb);

            for (size_t i=0; i<bytes; ++i)
            {
                uint8_t t0      = za[i];
                za[i]           = zb[i];
                zb[i]           = t0;
            }
        #else
            // 16-byte blocks
            uint32_t *xa    = reinterpret_cast<uint32_t *>(a);
            uint32_t *xb    = reinterpret_cast<uint32_t *>(b);
            for (; bytes >= 16 ; bytes -= 16, xa += 4, xb += 4)
            {
                uint32_t t0     = xa[0];
                uint32_t t1     = xa[1];
                uint32_t t2     = xa[2];
                uint32_t t3     = xa[3];

                xa[0]           = xb[0];
                xa[1]           = xb[1];
                xa[2]           = xb[2];
                xa[3]           = xb[3];

                xb[0]           = t0;
                xb[1]           = t1;
                xb[2]           = t2;
                xb[3]           = t3;
            }

            // 4-byte blocks
            for (; bytes >= 4 ; bytes -= 4, ++xa, ++xb)
            {
                uint32_t t0     = xa[0];
                xa[0]           = xb[0];
                xb[0]           = t0;
            }

            // 1-byte blocks
            uint8_t *ya    = reinterpret_cast<uint8_t *>(xa);
            uint8_t *yb    = reinterpret_cast<uint8_t *>(xb);

            for (size_t i=0; i<bytes; ++i)
            {
                uint8_t t0      = ya[i];
                ya[i]           = yb[i];
                yb[i]           = t0;
            }
        #endif /* ARCH_64BIT */
        }

        void base_backend_t::swap_rows(void *buf, size_t rows, size_t bytes_per_row)
        {
            uint8_t *a      = static_cast<uint8_t *>(buf);
            uint8_t *b      = &a[(rows - 1) * bytes_per_row];
            for ( ; a < b ; a += bytes_per_row, b -= bytes_per_row)
                memswap(a, b, bytes_per_row);
        }

        status_t base_backend_t::set_bg_color(backend_t *handle, const color_t *color)
        {
            if (color == NULL)
                return STATUS_BAD_ARGUMENTS;

            base_backend_t *_this = static_cast<base_backend_t *>(handle);
            _this->colBackground   = *color;
            return STATUS_OK;
        }

        status_t base_backend_t::get_bg_color(backend_t *handle, color_t *color)
        {
            if (color == NULL)
                return STATUS_BAD_ARGUMENTS;

            base_backend_t *_this = static_cast<base_backend_t *>(handle);
            *color  = _this->colBackground;
            return STATUS_OK;
        }

        status_t base_backend_t::locate(backend_t *handle, ssize_t left, ssize_t top, ssize_t width, ssize_t height)
        {
            base_backend_t *_this = static_cast<base_backend_t *>(handle);

            _this->viewLeft    = left;
            _this->viewTop     = top;
            _this->viewWidth   = width;
            _this->viewHeight  = height;

            return STATUS_OK;
        }
    }
}
