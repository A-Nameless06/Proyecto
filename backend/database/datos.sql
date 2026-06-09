USE CentroMedicoRASA;
GO

INSERT INTO ESPECIALIDAD (Nombre, Costo_Consulta, Descripcion) VALUES
('Cardiología',      1500.00, 'Diagnóstico y tratamiento de enfermedades del corazón'),
('Dermatología',     1300.00, 'Atención de enfermedades de la piel, cabello y uñas'),
('Ginecología',       800.00, 'Salud del sistema reproductor femenino'),
('Medicina General',  500.00, 'Consulta general y medicina preventiva'),
('Nefrología',        800.00, 'Diagnóstico y tratamiento de enfermedades renales'),
('Nutriología',       500.00, 'Orientación nutricional y planes alimenticios'),
('Oftalmología',      500.00, 'Diagnóstico y tratamiento de enfermedades oculares'),
('Oncología',        1200.00, 'Diagnóstico y tratamiento del cáncer'),
('Ortopedia',         300.00, 'Atención del sistema músculo-esquelético'),
('Pediatría',         700.00, 'Atención médica para niños y adolescentes');


INSERT INTO HORARIO (Hora_Inicio, Hora_Fin, Dia) VALUES
('07:00:00', '15:00:00', 'Lunes'),
('07:00:00', '15:00:00', 'Martes'),
('07:00:00', '15:00:00', 'Miércoles'),
('07:00:00', '15:00:00', 'Jueves'),
('07:00:00', '15:00:00', 'Viernes'),

('13:00:00', '21:00:00', 'Lunes'),
('13:00:00', '21:00:00', 'Martes'),
('13:00:00', '21:00:00', 'Miércoles'),
('13:00:00', '21:00:00', 'Jueves'),
('13:00:00', '21:00:00', 'Viernes'),

('08:00:00', '14:00:00', 'Sábado'),
('09:00:00', '13:00:00', 'Domingo');