/* Copyright (c) 2021 PaddlePaddle Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. */

#include <metal_stdlib>

#include "Common.metal"

using namespace metal;

struct ClipParam {
    float max;
    float min;
};

kernel void clip(texture2d_array<ftype, access::read> input[[texture(0)]],
    texture2d_array<ftype, access::write> outTexture[[texture(1)]],
    constant ClipParam& param[[buffer(0)]],
    uint3 gid[[thread_position_in_grid]]) {
    if (gid.x >= outTexture.get_width() || gid.y >= outTexture.get_height() ||
        gid.z >= outTexture.get_array_size())
        return;

    ftype4 r4 = input.read(gid.xy, gid.z);
    ftype4 max4 = ftype4(ftype(param.max));
    ftype4 min4 = ftype4(ftype(param.min));
    ftype4 out = clamp(r4, min4, max4);

    outTexture.write(out, gid.xy, gid.z);
}
