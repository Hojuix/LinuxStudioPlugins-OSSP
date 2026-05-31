/*
 * Copyright (C) 2020 Linux Studio Plugins Project <https://lsp-plug.in/>
 *           (C) 2020 Vladimir Sadovnikov <sadko4u@gmail.com>
 *
 * This file is part of lsp-r3d-base-lib
 * Created on: 18 апр. 2019 г.
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

#ifndef LSP_PLUG_IN_R3D_BASE_BACKEND_H_
#define LSP_PLUG_IN_R3D_BASE_BACKEND_H_

#include <lsp-plug.in/r3d/base/version.h>
#include <lsp-plug.in/r3d/iface/backend.h>
#include <lsp-plug.in/common/types.h>

namespace lsp
{
    namespace r3d
    {
        typedef struct base_backend_t: public backend_t
        {
            mat4_t              matProjection;
            mat4_t              matView;
            mat4_t              matWorld;

            color_t             colBackground;

            ssize_t             viewLeft;
            ssize_t             viewTop;
            ssize_t             viewWidth;
            ssize_t             viewHeight;

            static void         init_matrix_identity(mat4_t *m);
            static void         matrix_mul(mat4_t *r, const mat4_t *s, const mat4_t *m);

            explicit            base_backend_t();
            void                construct();

            static status_t     init(backend_t *handle);
            static void         destroy(backend_t *handle);

            static void         memswap(void *a, void *b, size_t bytes);
            static void         swap_rows(void *buf, size_t rows, size_t bytes_per_row);

            static status_t     locate(backend_t *handle, ssize_t left, ssize_t top, ssize_t width, ssize_t height);
            static status_t     set_matrix(backend_t *handle, matrix_type_t type, const mat4_t *m);
            static status_t     get_matrix(backend_t *handle, matrix_type_t type, mat4_t *m);
            static status_t     set_bg_color(backend_t *handle, const color_t *color);
            static status_t     get_bg_color(backend_t *handle, color_t *color);
            static status_t     get_location(backend_t *handle, ssize_t *left, ssize_t *top, ssize_t *width, ssize_t *height);

        } base_backend_t;
    } /* namespace r3d */
} /* namespace lsp */

#endif /* LSP_PLUG_IN_R3D_BASE_BACKEND_H_ */
