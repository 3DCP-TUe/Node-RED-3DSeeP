// Check if data exists
const mtec = msg.payload.mtec ?? {};
const gantry = msg.payload.gantry ?? {};
const mai = msg.payload.mai ?? {};
const material = msg.payload.material ?? {};
const vertico = msg.payload.vertico ?? {};
const printhead = msg.payload.printhead ?? {};

// Gantry arrays
var gantry_position = gantry.gantry_position ?? [NaN, NaN, NaN, NaN];
var gantry_velocity = gantry.gantry_velocity ?? [NaN, NaN, NaN, NaN];
var gantry_feedrate = gantry.gantry_feedrate ?? [NaN, NaN, NaN, NaN];
var gantry_r_parameters = gantry.gantry_r_parameters ?? [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN];

msg.payload = {

    // Desktop time
    'Time': msg.payload.time,

    // mtec
    'mtec_source_time': mtec.mtec_source_time ?? NaN,
	'mtec_water_pump_run': +mtec.mtec_water_pump_run ?? NaN,
	'mtec_water_solenoid_valve': +mtec.mtec_water_solenoid_valve ?? NaN,
	'mtec_water_water_valve': mtec.mtec_water_valve_actual ?? NaN,
    'mtec_water_temp': mtec.mtec_water_temp?.toFixed(2) ?? NaN,
    'mtec_water_flow_set': mtec.mtec_water_flow_set ?? NaN,
    'mtec_water_flow_actual': mtec.mtec_water_flow_actual?.toFixed(2) ?? NaN,
    'mtec_mixer_run': +mtec.mtec_mixer_run ?? NaN,
	'mtec_state_wet_material_probe': +mtec.mtec_state_wet_material_probe ?? NaN,
	'mtec_pump_speed_set': mtec.mtec_pump_speed_set ?? NaN,
    'mtec_pump_speed_actual': mtec.mtec_pump_speed_actual ?? NaN,

    // MAI
    'mai_source_time': mai.mai_source_time ?? NaN,
    'mai_water_run': +mai.mai_water_run ?? NaN,
    'mai_water_temp': mai.mai_water_temp?.toFixed(2) ?? NaN,
    'mai_water_flow_set': mai.mai_water_flow_set ?? NaN,
    'mai_water_flow_actual': mai.mai_water_flow_actual?.toFixed(2) ?? NaN,
    'mai_waterpump_ref_freq': mai.mai_waterpump_ref_freq ?? NaN,
    'mai_waterpump_output_freq': mai.mai_waterpump_output_freq ?? NaN,
    'mai_mixer_run': +mai.mai_mixer_run ?? NaN,
    'mai_pump_run': +mai.mai_pump_run ?? NaN,
    'mai_pump_speed': mai.mai_pump_speed ?? NaN,
    'mai_pump_ouput_current': mai.mai_pump_output_current ?? NaN,
    'mai_pump_output_power': mai.mai_pump_output_power ?? NaN,
    'mai_pump_vibration_mode': mai.mai_pump_vibration_mode ?? NaN,
    'mai_setting_water_pre_run': mai.mai_setting_water_pre_run?.toFixed(2) ?? NaN,
    'mai_setting_mixer_post_run': mai.mai_setting_mixer_post_run?.toFixed(2) ?? NaN,
    'mai_setting_wetprobe_covered_delay': mai.mai_setting_wetprobe_covered_delay ?? NaN,
    'mai_setting_wetprobe_uncovered_delay,': mai.mai_setting_wetprobe_uncovered_delay ?? NaN,

    // Gantry
    'gantry_source_time': gantry.gantry_source_time ?? NaN,
    'gantry_position_x': gantry_position[0].toFixed(2),
    'gantry_position_y': gantry_position[1].toFixed(2),
    'gantry_position_z': gantry_position[2].toFixed(2),
    'gantry_position_c': gantry_position[3].toFixed(2),
    'gantry_velocity_x': gantry_velocity[0].toFixed(2),
    'gantry_velocity_y': gantry_velocity[1].toFixed(2),
    'gantry_velocity_z': gantry_velocity[2].toFixed(2),
    'gantry_velocity_c': gantry_velocity[3].toFixed(2),
    'gantry_feedrate_x': gantry_feedrate[0].toFixed(2),
    'gantry_feedrate_y': gantry_feedrate[1].toFixed(2),
    'gantry_feedrate_z': gantry_feedrate[2].toFixed(2),
    'gantry_feedrate_c': gantry_feedrate[3].toFixed(2),
    'gantry_feedrate_overwrite': gantry.gantry_feedrate_overwrite?.toFixed(2) ?? NaN,
    'gantry_r100': gantry_r_parameters[0].toFixed(3),
    'gantry_r101': gantry_r_parameters[1].toFixed(3),
    'gantry_r102': gantry_r_parameters[2].toFixed(3),
    'gantry_r103': gantry_r_parameters[3].toFixed(3),
    'gantry_r104': gantry_r_parameters[4].toFixed(3),
    'gantry_r105': gantry_r_parameters[5].toFixed(3),
    'gantry_r106': gantry_r_parameters[6].toFixed(3),
    'gantry_r107': gantry_r_parameters[7].toFixed(3),
    'gantry_r108': gantry_r_parameters[8].toFixed(3),
    'gantry_r109': gantry_r_parameters[9].toFixed(3),

    // Material
    'material_source_time': material.material_source_time ?? NaN,
    'material_pressure_ai0': material.material_pressure_ai0?.toFixed(2) ?? NaN,
    'material_pressure_ai1': material.material_pressure_ai1?.toFixed(2) ?? NaN,
    'material_io_ai0': material.material_io_ai0?.toFixed(6) ?? NaN,
    'material_io_ai1': material.material_io_ai1?.toFixed(6) ?? NaN,
    'material_io_ai2': material.material_io_ai2?.toFixed(6) ?? NaN,
    'material_io_ai3': material.material_io_ai3?.toFixed(6) ?? NaN,
    'material_io_ai4': material.material_io_ai4?.toFixed(6) ?? NaN,
    'material_io_ai5': material.material_io_ai5?.toFixed(6) ?? NaN,
    'material_io_relative_humidity': material.material_io_relative_humidity?.toFixed(2) ?? NaN,
    'material_io_ambient_temperature': material.material_io_ambient_temperature?.toFixed(1) ?? NaN,
    'material_io_ao0': material.material_io_ao0?.toFixed(6) ?? NaN,
    'material_io_ao1': material.material_io_ao1?.toFixed(6) ?? NaN,
    'material_io_ao2': material.material_io_ao2?.toFixed(6) ?? NaN,
    'material_io_ao3': material.material_io_ao3?.toFixed(6) ?? NaN,
    'material_io_di0': +material.material_io_di0 ?? NaN,
    'material_io_di1': +material.material_io_di1 ?? NaN,
    'material_io_di2': +material.material_io_di2 ?? NaN,
    'material_io_di3': +material.material_io_di3 ?? NaN,
    'material_io_do0': +material.material_io_do0 ?? NaN,
    'material_io_do1': +material.material_io_do1 ?? NaN,
    'material_io_do2': +material.material_io_do2 ?? NaN,
    'material_io_do3': +material.material_io_do3 ?? NaN,
    'material_coriolis_mass_flow': material.material_coriolis_mass_flow?.toFixed(3) ?? NaN,
    'material_coriolis_volume_flow': material.material_coriolis_volume_flow?.toFixed(3) ?? NaN,
    'material_coriolis_density': material.material_coriolis_density?.toFixed(3) ?? NaN,
    'material_coriolis_dynamic_visco': material.material_coriolis_dynamic_visco?.toFixed(1) ?? NaN,
    'material_coriolis_temperature': material.material_coriolis_temperature?.toFixed(2) ?? NaN,
    'material_coriolis_exciter_current_0': material.material_coriolis_exciter_current_0?.toFixed(6) ?? NaN,
    'material_coriolis_oscillation_frequency_0': material.material_coriolis_oscillation_frequency_0?.toFixed(6) ?? NaN,
    'material_coriolis_oscillation_amplitude_0': material.material_coriolis_oscillation_amplitude_0?.toFixed(6) ?? NaN,
    'material_coriolis_oscillation_damping_0': material.material_coriolis_oscillation_damping_0?.toFixed(3) ?? NaN,
    'material_coriolis_signal_asymmetry': material.material_coriolis_signal_asymmetry?.toFixed(9) ?? NaN,
    'material_coriolis_exciter_current_1': material.material_coriolis_exciter_current_1?.toFixed(6) ?? NaN,
    'material_coriolis_oscillation_frequency_1': material.material_coriolis_oscillation_frequency_1?.toFixed(6) ?? NaN,
    'material_coriolis_oscillation_amplitude_1': material.material_coriolis_oscillation_amplitude_1?.toFixed(6) ?? NaN,
    'material_coriolis_oscillation_damping_1': material.material_coriolis_oscillation_damping_1?.toFixed(3) ?? NaN,
    'material_bronkhorst_read_alarm_info': material.material_bronkhorst_read_alarm_info?.toFixed(0) ?? NaN,
    'material_bronkhorst_read_read_setpoint': material.material_bronkhorst_read_setpoint?.toFixed(2) ?? NaN,
    'material_bronkhorst_read_measure': material.material_bronkhorst_read_measure?.toFixed(3) ?? NaN,
    'material_bronkhorst_read_temperature': material.material_bronkhorst_read_temperature?.toFixed(1) ?? NaN,
    'material_bronkhorst_read_density': material.material_bronkhorst_read_actual_density?.toFixed(1) ?? NaN,
    'material_bronkhorst_read_analog_input': material.material_bronkhorst_read_analog_input?.toFixed(0) ?? NaN,
    'material_bronkhorst_read_valve_output': material.material_bronkhorst_read_valve_output?.toFixed(0) ?? NaN,
    'material_bronkhorst_read_setpoint_slope': material.material_bronkhorst_read_setpoint_slope?.toFixed(0) ?? NaN,
    'material_peristaltic_pump_actual_velocity': material.material_peristaltic_pump_actual_velocity?.toFixed(3) ?? NaN,
    'material_peristaltic_pump_actual_power': material.material_peristaltic_pump_actual_power?.toFixed(3) ?? NaN,
    'material_peristaltic_pump_actual_current': material.material_peristaltic_pump_actual_current?.toFixed(3) ?? NaN,
    'material_peristaltic_pump_actual_torque': material.material_peristaltic_pump_actual_torque?.toFixed(3) ?? NaN,
    'material_r0': material.material_r0?.toFixed(6) ?? NaN,
    'material_r1': material.material_r1?.toFixed(6) ?? NaN,
    'material_r2': material.material_r2?.toFixed(6) ?? NaN,
    'material_r3': material.material_r3?.toFixed(6) ?? NaN,
    'material_r4': material.material_r4?.toFixed(6) ?? NaN,
    'material_r5': material.material_r5?.toFixed(6) ?? NaN,
    'material_r6': material.material_r6?.toFixed(6) ?? NaN,
    'material_r7': material.material_r7?.toFixed(6) ?? NaN,
    'material_r8': material.material_r8?.toFixed(6) ?? NaN,
    'material_r9': material.material_r9?.toFixed(6) ?? NaN,

    // Vertico
    'vertico_source_time': vertico.vertico_source_time ?? NaN,
    'vertico_is_remote': +vertico.vertico_is_remote ?? NaN,
    'vertico_is_open_loop': +vertico.vertico_is_open_loop ?? NaN,
    'vertico_actual_motor_velocity': vertico.vertico_motor_velocity_measured?.toFixed(0) ?? NaN,
    'vertico_actual_flow_ml_min': vertico.vertico_flow_measured_ml_min?.toFixed(2) ?? NaN,
    'vertico_actual_flow_ma': vertico.vertico_flow_measured_ma?.toFixed(6) ?? NaN,
    'vertico_actual_pressure': vertico.vertico_pressure_measured?.toFixed(1) ?? NaN,
    'vertico_local_setpoint_open_loop': vertico.vertico_local_setpoint_open_loop?.toFixed(0) ?? NaN,
    'vertico_local_setpoint_closed_loop': vertico.vertico_local_setpoint_closed_loop?.toFixed(2) ?? NaN,
    'vertico_remote_start_stop': +vertico.vertico_remote_start_stop ?? NaN,
    'vertico_remote_setpoint_open_loop': vertico.vertico_remote_setpoint_open_loop?.toFixed(0) ?? NaN,
    'vertico_remote_setpoint_closed_loop': vertico.vertico_remote_setpoint_closed_loop?.toFixed(2) ?? NaN,
    'vertico_pid_p': vertico.vertico_pid_p?.toFixed(1) ?? NaN,
    'vertico_pid_i': vertico.vertico_pid_i?.toFixed(1) ?? NaN,
    'vertico_pid_d': vertico.vertico_pid_d?.toFixed(2) ?? NaN,
    'vertico_ai3': vertico.vertico_ai3?.toFixed(6) ?? NaN,
    'vertico_ao0': vertico.vertico_ao0?.toFixed(6) ?? NaN,
    'vertico_do3': +vertico.vertico_do3 ?? NaN,

    // Printhead
    'printhead_source_time': printhead.printhead_source_time ?? NaN,
    'printhead_power_on_left': +printhead.printhead_power_on_left ?? NaN,
    'printhead_move_jog_backward_left': +printhead.printhead_move_jog_backward_left ?? NaN,
    'printhead_move_jog_forward_left': +printhead.printhead_move_jog_forward_left ?? NaN,
    'printhead_velocity_jog_left': printhead.printhead_velocity_jog_left?.toFixed(1) ?? NaN,
    'printhead_actual_velocity_left': printhead.printhead_actual_velocity_left?.toFixed(1) ?? NaN,
    'printhead_actual_power_left': printhead.printhead_actual_power_left?.toFixed(3) ?? NaN,
    'printhead_actual_current_left': printhead.printhead_actual_current_left?.toFixed(3) ?? NaN,
    'printhead_actual_torque_left': printhead.printhead_actual_torque_left?.toFixed(3) ?? NaN,
    'printhead_power_on_right': +printhead.printhead_power_on_right ?? NaN,
    'printhead_move_jog_backward_right': +printhead.printhead_move_jog_backward_right ?? NaN,
    'printhead_move_jog_forward_right': +printhead.printhead_move_jog_forward_right ?? NaN,
    'printhead_velocity_jog_right': printhead.printhead_velocity_jog_right?.toFixed(1) ?? NaN,
    'printhead_actual_velocity_right': printhead.printhead_actual_velocity_right?.toFixed(1) ?? NaN,
    'printhead_actual_power_right': printhead.printhead_actual_power_right?.toFixed(3) ?? NaN,
    'printhead_actual_current_right': printhead.printhead_actual_current_right?.toFixed(3) ?? NaN,
    'printhead_actual_torque_right': printhead.printhead_actual_torque_right?.toFixed(3) ?? NaN,
    'printhead_pressure': printhead.printhead_pressure?.toFixed(2) ?? NaN,
    'printhead_box1_ai0': printhead.printhead_box1_ai0?.toFixed(6) ?? NaN,
    'printhead_box1_ai1': printhead.printhead_box1_ai1?.toFixed(6) ?? NaN,
    'printhead_box1_ai2': printhead.printhead_box1_ai2?.toFixed(6) ?? NaN,
    'printhead_box1_ai3': printhead.printhead_box1_ai3?.toFixed(6) ?? NaN,
    'printhead_box1_ai4': printhead.printhead_box1_ai4?.toFixed(6) ?? NaN,
    'printhead_box1_ai5': printhead.printhead_box1_ai5?.toFixed(6) ?? NaN,
    'printhead_box1_ai6': printhead.printhead_box1_ai6?.toFixed(6) ?? NaN,
    'printhead_box1_ai7': printhead.printhead_box1_ai7?.toFixed(6) ?? NaN,
    'printhead_box2_ai0': printhead.printhead_box2_ai0?.toFixed(6) ?? NaN,
    'printhead_box2_ai1': printhead.printhead_box2_ai1?.toFixed(6) ?? NaN,
    'printhead_box2_ai2': printhead.printhead_box2_ai2?.toFixed(6) ?? NaN,
    'printhead_box2_ai3': printhead.printhead_box2_ai3?.toFixed(6) ?? NaN
};


return msg;






