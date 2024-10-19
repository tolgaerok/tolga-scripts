def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    else:
        pivot = arr[len(arr) // 2]
        left = [x for x in arr if str(x) < str(pivot)]
        middle = [x for x in arr if str(x) == str(pivot)]
        right = [x for x in arr if str(x) > str(pivot)]
        return quick_sort(left) + middle + quick_sort(right)
arr = "The first time I heard about “Visual Studio”, I thought it was the same as “Visual Studio Code”. I don’t know why Microsoft decided to confuse everyone with the names of those two development tools. But that’s a story for another day.".split()
print("Original array:", arr)
sorted_arr = quick_sort(arr)
print("Sorted array:", sorted_arr)
