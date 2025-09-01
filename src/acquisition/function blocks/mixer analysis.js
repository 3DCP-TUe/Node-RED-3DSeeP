// SPDX-License-Identifier: GPL-3.0-or-later
// Node-RED-3DSeeP
// Project: https://github.com/3DCP-TUe/Node-RED-3DSeeP
//
// Copyright (c) 2024-2025 Eindhoven University of Technology
//
// Authors:
//  - Arjen Deetman (2024-2025)
//
// For license details, see the LICENSE file in the project root.

// On Start
context.set('prev_mixer_run', false);
context.set('prev_mixer_stop', new Date().getTime() / 1000);
context.set('prev_mixer_start', new Date().getTime() / 1000);
context.set('batch_time', 0.0);
context.set('interval_time', 0.0);
context.set('queue', []);

// On Message
if (msg.payload !== context.get('prev_mixer_run')) {
   
    context.set('prev_mixer_run', msg.payload);
	
	time = new Date().getTime() / 1000;
	queue = context.get('queue');
	prev_start = context.get('prev_mixer_start')
	prev_stop = context.get('prev_mixer_stop')
	prev_batch_time = context.get('batch_time');
	prev_interval_time = context.get('interval_time');
	
	if (msg.payload == false)
	{
	    batch_time = time - prev_start;
		context.set('prev_mixer_stop', time);
		context.set('batch_time', batch_time);
		
		msg.batch_time = batch_time;
		msg.interval_time = prev_interval_time;
		msg.prediction = prev_batch_time / prev_interval_time * 1.0;

		let sum = queue.reduce((acc, curr) => acc + curr, 0);
		msg.mean = sum / queue.length;
		
		return msg;
	}
	else
	{
		interval_time = time - prev_start;
	    msg.batch_time = prev_batch_time;
		msg.interval_time = interval_time;
		msg.prediction = prev_batch_time / interval_time * 1.0;
		
		queue.push(msg.prediction);
		
		if(queue.length > 8)
		{
		    queue.shift();
		}
		
		let sum = queue.reduce((acc, curr) => acc + curr, 0);
		msg.mean = sum / queue.length;
		
		context.set('queue', queue);
		context.set('interval_time', interval_time);
		context.set('prev_mixer_start', time);
		return msg;
	}
}