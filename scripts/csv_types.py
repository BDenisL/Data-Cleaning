import pandas as pd
import numpy as np

def detectar_tipos_csv(ruta_csv, separador=","):
    try:
        # Leer el CSV
        df = pd.read_csv(ruta_csv, sep=separador)

        # Mostrar tipos detectados por pandas
        print("Tipos detectados por Pandas:")
        print(df.dtypes)
        print("\n--- Detección personalizada ---")

        # Detección más precisa
        for columna in df.columns:
            valores = df[columna].dropna()  # Ignorar valores vacíos
            tipo_detectado = "cadena"

            # Si todos los valores son enteros
            if all(valores.apply(lambda x: str(x).isdigit())):
                tipo_detectado = "entero"
            # Si todos los valores son numéricos pero con decimales
            elif np.all(pd.to_numeric(valores, errors="coerce").notnull()):
                if any("." in str(v) for v in valores):
                    tipo_detectado = "flotante"
                else:
                    tipo_detectado = "entero"
            # Intentar detectar fechas
            try:
                pd.to_datetime(valores, errors="raise")
                tipo_detectado = "fecha"
            except Exception:
                pass

            print(f"Columna '{columna}': {tipo_detectado}")

    except FileNotFoundError:
        print(f"Error: No se encontró el archivo '{ruta_csv}'.")
    except pd.errors.EmptyDataError:
        print("Error: El archivo CSV está vacío.")
    except Exception as e:
        print(f"Ocurrió un error: {e}")

# Ejemplo de uso
if __name__ == "__main__":
    detectar_tipos_csv("Limpieza.csv", separador=",")
