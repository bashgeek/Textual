/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2008 - 2010 Satoshi Nakagawa <psychs AT limechat DOT net>
 * Copyright (c) 2010 - 2018 Codeux Software, LLC & respective contributors.
 *       Please see Acknowledgements.pdf for additional information.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Textual, "Codeux Software, LLC", nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *********************************************************************** */

@objc(TLOTimer)
final class TLOTimer: NSObject
{
	@objc let actionBlock: (TLOTimer) -> Void

	@objc var queue: DispatchQueue?
	@objc var context: Any?

	@objc private(set) var startTime: TimeInterval = 0
	@objc private(set) var interval: TimeInterval = 0
	@objc private(set) var repeatTimer: Bool = false
	@objc private(set) var iterations: UInt = 0
	@objc private(set) var currentIteration: UInt = 0

	@objc var timerIsActive: Bool { timerSource != nil }
	@objc var timeRemaining: TimeInterval { interval - (CFAbsoluteTimeGetCurrent() - startTime) }

	private var timerSource: dispatch_source_t?

	@objc class func timerWithActionBlock(_ actionBlock: @escaping (TLOTimer) -> Void) -> TLOTimer
	{
		return TLOTimer(actionBlock: actionBlock)
	}

	@objc class func timerWithActionBlock(_ actionBlock: @escaping (TLOTimer) -> Void, onQueue queue: DispatchQueue) -> TLOTimer
	{
		return TLOTimer(actionBlock: actionBlock, onQueue: queue)
	}

	@objc convenience init(actionBlock: @escaping (TLOTimer) -> Void)
	{
		self.init(actionBlock: actionBlock, onQueue: nil)
	}

	@objc init(actionBlock: @escaping (TLOTimer) -> Void, onQueue queue: DispatchQueue?)
	{
		self.actionBlock = actionBlock
		super.init()
		self.queue = queue
	}

	deinit
	{
		stop()
	}

	@objc func start(_ timerInterval: TimeInterval)
	{
		start(timerInterval, onRepeat: false, iterations: 0)
	}

	@objc func start(_ timerInterval: TimeInterval, onRepeat repeatTimer: Bool)
	{
		start(timerInterval, onRepeat: repeatTimer, iterations: 0)
	}

	@objc func start(_ timerInterval: TimeInterval, onRepeat repeatTimer: Bool, iterations: UInt)
	{
		precondition(timerInterval > 0)

		stop()

		let sourceQueue = queue ?? DispatchQueue.main

		let source = XRScheduleBlockOnQueue(sourceQueue, {
			self.fireTimer()
		}, timerInterval, repeatTimer)

		self.interval = timerInterval
		self.repeatTimer = repeatTimer
		self.iterations = iterations
		self.currentIteration = 0
		self.timerSource = source

		if let source = source {
			XRResumeScheduledBlock(source)
		}

		self.startTime = CFAbsoluteTimeGetCurrent()
	}

	@objc func stop()
	{
		guard let source = timerSource else { return }

		XRCancelScheduledBlock(source)

		timerSource = nil
	}

	private func stopIfNeeded()
	{
		if iterations > 0 && iterations == currentIteration {
			stop()
		}
	}

	private func fireTimer()
	{
		currentIteration += 1

		stopIfNeeded()

		actionBlock(self)
	}
}
