import tkinter as tk
import serial.tools.list_ports
import serial
import struct
from tkinter import messagebox
import threading

#Variables globales
label1 = ""
label2 = ""
label3 = ""
entrada = ""
entrada2 = ""
ser =  serial.Serial(port='COM6', baudrate=9600, timeout=2)
Cuenta_Recibidos  = 0
Cuenta_Procesados = 0
Dato = 0
def Actualizar_Display(Cuenta_Procesados, Cuenta_Recibidos, Dato):
        label1.config(text=f"Contador Procesados: {Cuenta_Procesados}")
        label2.config(text=f"Contador Recibidos: {Cuenta_Recibidos}")
        label3.config(text=f"Dato Recibido: {Dato}")
        #root.update()

def borrar_mensaje(event):
       if entrada.get() == 'Ingrese Dato':
            entrada.delete(0, tk.END)
            entrada.config(fg='black')

def restaurar_mensaje(event):
        if entrada.get() == '':
            entrada.insert(0, 'Ingrese Dato')
            entrada.config(fg='gray')

def borrar_mensaje2(event2):
        if entrada2.get() == 'Ingrese ID destinatario':
            entrada2.delete(0, tk.END)
            entrada2.config(fg='black')

def restaurar_mensaje2(event2):
        if entrada2.get() == '':
            entrada2.insert(0, 'Ingrese ID destinatario')
            entrada2.config(fg='gray')

def obtener_datos():
        # Obtener el texto ingresado en el widget de entrada
        global ser     
        texto1 = int(entrada.get())
        texto2 = int(entrada2.get())
        data = texto1*16+texto2
        bytes_valor = bytes([data])  
        ser.write(bytes_valor)
        ser.close
        

    # Recibir datos
def Thread_Recibir():
            global ser
            global Cuenta_Recibidos;  # Contador de recibidos
            global Cuenta_Procesados; # Contador de procesados
            global Dato
            while True:                 
                if ser.inWaiting() != 0:                              # Si hay algo en el puerto serial esperando...
                    data_read = ser.read(1)                           # Captura la info
                    

                    Cuenta_Recibidos = Cuenta_Recibidos + 1           # Aumenta el contador de recibidos
                    data = "{:08b}".format(int(data_read.hex(),16))   # Esto transforma a cadena de 8 bits
                    data = [int(x) for x in list(str(data))]          # Esto transforma a una lista
                    if (data[4:8] == [0,0,0,0]):                      # Si los bits de indentificador son iguales a 0...
                        Cuenta_Procesados = Cuenta_Procesados + 1     # Aumenta el contador de procesados
                        Dato = data[0:4]
                        print (data_read)
                        print (data)
                        print (Cuenta_Recibidos)
                        print (Cuenta_Procesados)
                        print ('\n')
                        Actualizar_Display(Cuenta_Procesados, Cuenta_Recibidos, Dato)
                        
                    else: 
                        print (data)
                        print (Cuenta_Recibidos)
                        print (Cuenta_Procesados)
                        print ('\n')
                        Actualizar_Display(Cuenta_Procesados, Cuenta_Recibidos, Dato)
                        
            ser.close()

                   
          




def Thread2():

    root = tk.Tk()
    global label1
    global label2
    global label3
    global entrada
    global entrada2
    
    # Crear los tres label
    label1 = tk.Label(root, text="Contador Procesados: 0", bg="red", fg="white")
    label2 = tk.Label(root, text="Contador Recibidos: 0", bg="green", fg="white")
    label3 = tk.Label(root, text="Dato Recibido: 0", bg="blue", fg="white")
    # Colocar los label de izquierda a derecha
    label1.grid(row=0, column=1)
    label2.grid(row=0, column=3)
    label3.grid(row=4, column=3)

    # Crear el widget de entrada de texto
    entrada = tk.Entry(root, fg='gray')
    entrada.insert(0, "Ingrese Dato")
    entrada.bind('<FocusIn>', borrar_mensaje)
    entrada.bind('<FocusOut>', restaurar_mensaje)
    entrada.grid(row=1, column=1)

    entrada2 = tk.Entry(root, fg='gray')
    entrada2.insert(0, "Ingrese ID destinatario")
    entrada2.bind('<FocusIn>', borrar_mensaje2)
    entrada2.bind('<FocusOut>', restaurar_mensaje2)
    entrada2.grid(row=1, column=3)

        # Crear el botón para obtener los datos del widget de entrada
    boton = tk.Button(root, text="Enviar", command=obtener_datos)
    boton.grid(row=2, column=2)

    ports = serial.tools.list_ports.comports()
        # Crear una variable de control para la opción seleccionada
    opcion_seleccionada = tk.StringVar()
        # Crear una lista de opciones para la lista desplegable
    opciones = ports
      # Establecer la opción por defecto
    opcion_seleccionada.set(opciones[0])
        # Crear un widget OptionMenu y asignarle la variable de control y las opciones
    lista_desplegable = tk.OptionMenu(root, opcion_seleccionada, *opciones)
        # Mostrar el widget en la ventana
    lista_desplegable.grid(row=5, column=3)
    root.mainloop()


t1 = threading.Thread(target=Thread_Recibir)
t2 = threading.Thread(target=Thread2)

t1.start()
t2.start()

t1.join()
t2.join()



