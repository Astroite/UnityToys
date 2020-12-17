using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Astroite
{
    public static class NumberConfig
    {
        public static float OnePerRow = 0.25f;

        public static Vector4 UV_TilingOffset_0 = new Vector4(OnePerRow, OnePerRow, 0, 0);
        public static Vector4 UV_TilingOffset_1 = new Vector4(OnePerRow, OnePerRow, 0.25f, 0);
        public static Vector4 UV_TilingOffset_2 = new Vector4(OnePerRow, OnePerRow, 0.5f, 0);
        public static Vector4 UV_TilingOffset_3 = new Vector4(OnePerRow, OnePerRow, 0.75f, 0);
        public static Vector4 UV_TilingOffset_4 = new Vector4(OnePerRow, OnePerRow, 0, 0.25f);
        public static Vector4 UV_TilingOffset_5 = new Vector4(OnePerRow, OnePerRow, 0.25f, 0.25f);
        public static Vector4 UV_TilingOffset_6 = new Vector4(OnePerRow, OnePerRow, 0.5f, 0.25f);
        public static Vector4 UV_TilingOffset_7 = new Vector4(OnePerRow, OnePerRow, 0.75f, 0.25f);
        public static Vector4 UV_TilingOffset_8 = new Vector4(OnePerRow, OnePerRow, 0, 0.5f);
        public static Vector4 UV_TilingOffset_9 = new Vector4(OnePerRow, OnePerRow, 0.25f, 0.5f);
        public static Vector4 UV_TilingOffset_A = new Vector4(OnePerRow, OnePerRow, 0.5f, 0.5f);
        public static Vector4 UV_TilingOffset_B = new Vector4(OnePerRow, OnePerRow, 0.75f, 0.5f);
        public static Vector4 UV_TilingOffset_C = new Vector4(OnePerRow, OnePerRow, 0, 0.75f);
        public static Vector4 UV_TilingOffset_D = new Vector4(OnePerRow, OnePerRow, 0.25f, 0.75f);
        public static Vector4 UV_TilingOffset_E = new Vector4(OnePerRow, OnePerRow, 0.5f, 0.75f);
        public static Vector4 UV_TilingOffset_F = new Vector4(OnePerRow, OnePerRow, 0.75f, 0.75f);

        public static List<Vector4> UV_TilingOffsets = new List<Vector4>{   UV_TilingOffset_0, 
                                                                            UV_TilingOffset_1,
                                                                            UV_TilingOffset_2,
                                                                            UV_TilingOffset_3,
                                                                            UV_TilingOffset_4,
                                                                            UV_TilingOffset_5,
                                                                            UV_TilingOffset_6,
                                                                            UV_TilingOffset_7,
                                                                            UV_TilingOffset_8,
                                                                            UV_TilingOffset_9,
                                                                            UV_TilingOffset_A,
                                                                            UV_TilingOffset_B,
                                                                            UV_TilingOffset_C,
                                                                            UV_TilingOffset_D,
                                                                            UV_TilingOffset_E,
                                                                            UV_TilingOffset_F,
        };
    }
}

