/*
 * Copyright (C) 2020 Linux Studio Plugins Project <https://lsp-plug.in/>
 *           (C) 2020 Vladimir Sadovnikov <sadko4u@gmail.com>
 *
 * This file is part of lsp-3rd-party
 * Created on: 23 нояб. 2020 г.
 *
 * lsp-3rd-party is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * lsp-3rd-party is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with lsp-3rd-party. If not, see <https://www.gnu.org/licenses/>.
 */

#include <ardour/inline-display.h>
#include <clap/clap.h>
#include <ladspa/ladspa.h>
#include <lv2/core/lv2.h>
#include <steinberg/vst2.h>

#include <lsp-plug.in/test-fw/utest.h>

UTEST_BEGIN("3rdparty", headers)
    UTEST_MAIN
    {
        printf("3rd party headers OK\n");
    }
UTEST_END


