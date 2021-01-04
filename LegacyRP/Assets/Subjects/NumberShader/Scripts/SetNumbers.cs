using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Astroite
{
    [ExecuteInEditMode]
    public class SetNumbers : MonoBehaviour
    {
        // Inspector
        public string Message;

        private const int MaxFigure = 5;
        private Material m_material;


        private void OnEnable()
        {
            m_material = GetComponent<MeshRenderer>().sharedMaterial;
            SetUVTilingOffset(Message);
        }

        private void Update()
        {
            
        }

        private void SetUVTilingOffset(string message)
        {
            char[] chars = SplitStringToCharList(message);
            Vector4[] messageArray = new Vector4[MaxFigure];
            for (int i = 0; i < MaxFigure; i++)
            {
                messageArray[i] = NumberConfig.GetUVTilingOffsetFromChar(chars[i]);
            }

            m_material.SetVectorArray("numbers", messageArray);
        }

        private char[] SplitStringToCharList(string message)
        {
            char[] chars = new char[MaxFigure];
            char[] tmp = message.ToCharArray();
            for (int i = 0; i < MaxFigure; i++)
            {
                if (i < tmp.Length)
                    chars[i] = tmp[i];
                else
                    chars[i] = 'f';
            }
            return chars;
        }




        //private void SetUVTilingOffset(int number)
        //{
        //    List<int> numbers = SplitInt2IntList(number);
        //    Vector4[] numberArray = new Vector4[numbers.Count];

        //    for (int i = 0; i < numberArray.Length; i++)
        //    {
        //        numberArray[i] = NumberConfig.UV_TilingOffsets[numbers[i]];
        //    }

        //    if (m_material)
        //        m_material.SetVectorArray("numbers", numberArray);
        //}

        //private List<int> SplitInt2IntList(int number)
        //{
        //    List<int> numbers = new List<int>();
        //    while (number / 10 != 0)
        //    {
        //        numbers.Add(number % 10);
        //        number /= 10;
        //    }
        //    numbers.Add(number % 10);
        //    numbers.Reverse();
        //    return numbers;
        //}
    }
}