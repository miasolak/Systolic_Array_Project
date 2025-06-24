import numpy as np
import os
M = 5  # broj vrsta
N = 5 # broj kolona
K = 10  # broj matrica
folder = "C:/Vivado/Systolic_Array"

def generate_random_matrix(n_rows=N, n_cols=M, low=0, high=10):
    return np.random.randint(low=low, high=high, size=(n_rows, n_cols)  )


# 📝 Funkcija za pisanje matrice po kolonama odozdo nagore (A i B)
def write_matrix_columnwise(foldername, filename, matrix):
    os.makedirs(foldername, exist_ok=True)
    path = os.path.join(foldername, filename)
    with open(path, 'a') as f:
        for col in reversed(range(matrix.shape[1])):
            for row in range(matrix.shape[0]):
                f.write(f"{matrix[row][col]}\n")
    print(f"✅ Upisano: {path}")



# 📝 Funkcija za pisanje vektora (niza)
def write_vector(foldername, filename, vector):
    os.makedirs(foldername, exist_ok=True)
    path = os.path.join(foldername, filename)
    with open(path, 'a') as f:
        for val in vector:
            f.write(f"{val}\n")
    print(f"✅ Upisano: {path}")
    

def write_matrix_rowwise_bottom_to_top(foldername, filename, matrix):
    """
    Upisuje redove matrice od poslednjeg ka prvom, po kolonama (sleva nadesno),
    i snima u fajl u zadatom folderu.
    """
    rows, cols = matrix.shape
    output = []

    for row in reversed(range(rows)):
        for col in range(cols):
            output.append(matrix[row][col])

    # Puna putanja
    full_path = os.path.join(foldername, filename)

    with open(full_path, 'a') as f:
        for val in output:
            f.write(f"{val}\n")
    # # Snimi podatke
    # np.savetxt(full_path, output, fmt="%d")




# ✅ OBRIŠI FAJLOVE NA POČETKU
for fname in ["A.txt", "B.txt", "C.txt"]:
    full_path = os.path.join(folder, fname)
    with open(full_path, 'w') as f:
        if fname in ["A.txt", "B.txt"]:
            f.write(f"{K}\n")  # upiši broj K kao prvu liniju

for i in range(K):
    # Primer poziva:
    A = generate_random_matrix()
    B = generate_random_matrix()

    # A = np.array([
    #     [1, 2, 3],
    #     [4, 5, 6],
    #     [7, 8, 9]
    # ])

    # B = np.array([
    #     [10, 20, 30],
    #     [40, 50, 60],
    #     [70, 80, 90]
    # ])



    # 🟡 C je sada vektor od 3 vrednosti: skalari po kolonama
    C = np.zeros(M, dtype=int)
    for col in range(M):
        C[col] = np.dot(A[:, col], B[:, col])  # skalarni proizvod kolone A i B
    print("A =\n", A)
    print("B =\n", B)
    print("C =\n", C)

    # ✅ Upis u fajlove
    write_matrix_columnwise("C:/Vivado/Systolic_Array", "A.txt", A)
    write_matrix_rowwise_bottom_to_top("C:/Vivado/Systolic_Array", "B.txt", B)
    write_vector("C:/Vivado/Systolic_Array", "C.txt", C)

    #write_vector("C", "C.txt", C)
    print("Putanja do A.txt:", os.path.abspath("A/A.txt"))
    print("🎉 Zavrseno.")
