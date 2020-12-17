using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Astroite
{
    [ExecuteInEditMode]
    public class SetNumbers : MonoBehaviour
    {
        // Inspector
        public int Number;

        private List<int> m_numbers;

        private void OnEnable()
        {
            splitInt2IntList(Number);
        }

        private List<int> splitInt2IntList(int number)
        {
            List<int> numbers = new List<int>();

            while(number / 10 != 0)
            {
                numbers.Add(number % 10);
                number /= 10;
                Debug.Log(number);
            }

            return numbers;
        }
    }
}