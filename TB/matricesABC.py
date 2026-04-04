import numpy as np
import os

M = 4  # number of columns
N = 7  # number of rows
K = 6  # number of matrix pairs
folder = "C:/Vivado/Systolic_Array"


def generate_random_matrix(n_rows=N, n_cols=M, low=1, high=30):
    return np.random.randint(low=low, high=high, size=(n_rows, n_cols))


# Writes a matrix column by column, from the last column to the first
def write_matrix_columnwise(foldername, filename, matrix):
    os.makedirs(foldername, exist_ok=True)
    path = os.path.join(foldername, filename)
    with open(path, 'a') as f:
        for col in reversed(range(matrix.shape[1])):
            for row in range(matrix.shape[0]):
                f.write(f"{matrix[row][col]}\n")
    print(f" Written to: {path}")


# Writes a vector to a file, one value per line
def write_vector(foldername, filename, vector):
    os.makedirs(foldername, exist_ok=True)
    path = os.path.join(foldername, filename)
    with open(path, 'a') as f:
        for val in vector:
            f.write(f"{val}\n")
    print(f" Written to: {path}")


def write_matrix_rowwise_bottom_to_top(foldername, filename, matrix):
    """
    Writes matrix rows starting from the last row to the first,
    storing elements left to right within each row.
    """
    rows, cols = matrix.shape
    output = []

    for row in reversed(range(rows)):
        for col in range(cols):
            output.append(matrix[row][col])

    full_path = os.path.join(foldername, filename)

    with open(full_path, 'a') as f:
        for val in output:
            f.write(f"{val}\n")


# Clear output files at the beginning
for fname in ["A.txt", "B.txt", "C.txt"]:
    full_path = os.path.join(folder, fname)
    with open(full_path, 'w') as f:
        if fname in ["A.txt", "B.txt"]:
            f.write(f"{K}\n")  # store K as the first line


for i in range(K):
    A = generate_random_matrix()
    B = generate_random_matrix()

    # Example matrices for manual testing
    # A = np.array([
    #     [10, 20, 30],
    #     [40, 50, 60],
    #     [70, 80, 90]
    # ])

    # B = np.array([
    #     [1, 2, 3],
    #     [4, 5, 6],
    #     [7, 8, 9]
    # ])

    # C is a vector containing the dot product of corresponding columns
    C = np.zeros(M, dtype=int)
    for col in range(M):
        C[col] = np.dot(A[:, col], B[:, col])

    print("A =\n", A)
    print("B =\n", B)
    print("C =\n", C)

    # Write generated data to files
    write_matrix_columnwise("C:/Vivado/Systolic_Array", "A.txt", A)
    write_matrix_rowwise_bottom_to_top("C:/Vivado/Systolic_Array", "B.txt", B)
    write_vector("C:/Vivado/Systolic_Array", "C.txt", C)

    print("Path to A.txt:", os.path.abspath("A/A.txt"))
    print("Done.")