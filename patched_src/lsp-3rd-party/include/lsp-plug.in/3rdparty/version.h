/*
 * Copyright (C) 2020 Linux Studio Plugins Project <https://lsp-plug.in/>
 *           (C) 2020 Vladimir Sadovnikov <sadko4u@gmail.com>
 *
 * This file is part of lsp-3rd-party
 * Created on: 3 мая 2020 г.
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

#ifndef LSP_PLUG_IN_3RD_PARTY_VERSION_H_
#define LSP_PLUG_IN_3RD_PARTY_VERSION_H_

//-----------------------------------------------------------------------------
// Version of headers
#define LSP_3RD_PARTY_MAJOR             1
#define LSP_3RD_PARTY_MINOR             0
#define LSP_3RD_PARTY_MICRO             27

#ifdef LSP_COMMON_LIB_BUILTIN
    #define LSP_3RD_PARTY_EXPORT
    #define LSP_3RD_PARTY_CEXPORT
    #define LSP_3RD_PARTY_IMPORT        LSP_SYMBOL_IMPORT
    #define LSP_3RD_PARTY_CIMPORT       LSP_CSYMBOL_IMPORT
#else
    #define LSP_3RD_PARTY_EXPORT        LSP_SYMBOL_EXPORT
    #define LSP_3RD_PARTY_CEXPORT       LSP_CSYMBOL_EXPORT
    #define LSP_3RD_PARTY_IMPORT        LSP_SYMBOL_IMPORT
    #define LSP_3RD_PARTY_CIMPORT       LSP_CSYMBOL_IMPORT
#endif

#endif /* LSP_PLUG_IN_3RD_PARTY_VERSION_H_ */
