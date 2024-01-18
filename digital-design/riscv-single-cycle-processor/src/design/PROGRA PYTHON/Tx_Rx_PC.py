import tkinter as tk
import serial.tools.list_ports
import serial

# Configurar puerto
ser = serial.Serial(
    port = 'COM5',
    baudrate = 9600,
    timeout = 2
)

ser.isOpen()

# Enviar datos
def Enviar_datos (datos):
    ser.write(datos)

# Recibir datos
Cuenta_Recibidos = 0;  # Contador de recibidos
Cuenta_Procesados = 0; # Contador de procesados

def Thread_Recibir():
    def Recibir_datos ():
        while True:
            if ser.inWaiting() != 0:                              # Si hay algo en el puerto serial esperando...
                data_read = ser.read(1)                           # Captura la info
                Cuenta_Recibidos = Cuenta_Recibidos + 1           # Aumenta el contador de recibidos
                data = "{:08b}".format(int(data_read.hex(),16))   # Esto transforma a cadena de 8 bits
                data = [int(x) for x in list(str(data))]          # Esto transforma a una lista
                if (data[4:8] == [0,0,0,0]):                      # Si los bits de indentificador son iguales a 0...
                    Cuenta_Procesados = Cuenta_Procesados + 1     # Aumenta el contador de procesados
                    print (data_read)
                    print (data)
                print (Cuenta_Recibidos)
                print (Cuenta_Procesados)
                print ('\n')
            else: 
                print (data)
                print (Cuenta_Recibidos)
                print (Cuenta_Procesados)
                print ('\n')
            
    hilo = threading.Thread(target=Recibir_datos())
    hilo.start()
