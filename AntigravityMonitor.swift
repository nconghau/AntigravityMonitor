import SwiftUI
import AppKit
import WebKit

// MARK: - Native Bridge
class WebKitBridge: NSObject, WKScriptMessageHandler {
    weak var window: NSWindow?
    var onRefresh: (() -> Void)?
    var scanner: AgentScanner?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any],
              let action = dict["action"] as? String else { return }

        if action == "toggleAlwaysOnTop" {
            DispatchQueue.main.async { [weak self] in
                guard let win = self?.window ?? NSApplication.shared.windows.first else { return }
                if win.level == .floating {
                    win.level = .normal
                } else {
                    win.level = .floating
                }
            }
        } else if action == "refresh" {
            onRefresh?()
        } else if action == "openWorkspace" {
            let agentId = dict["agentId"] as? String ?? ""
            let workspace = scanner?.getWorkspaceForAgent(agentId: agentId) ?? FileManager.default.homeDirectoryForCurrentUser.path
            DispatchQueue.main.async {
                let ideUrl = URL(fileURLWithPath: "/Applications/Antigravity IDE.app")
                if FileManager.default.fileExists(atPath: ideUrl.path) {
                    let config = NSWorkspace.OpenConfiguration()
                    NSWorkspace.shared.open([URL(fileURLWithPath: workspace)], withApplicationAt: ideUrl, configuration: config, completionHandler: nil)
                } else {
                    NSWorkspace.shared.open(URL(fileURLWithPath: workspace))
                }
            }
        } else if action == "openTerminal" {
            let agentId = dict["agentId"] as? String ?? ""
            let workspace = scanner?.getWorkspaceForAgent(agentId: agentId) ?? FileManager.default.homeDirectoryForCurrentUser.path
            DispatchQueue.main.async {
                let script = "tell application \"Terminal\" to do script \"cd '\(workspace)' && (which agy-top >/dev/null 2>&1 && agy-top || ls -la)\""
                if let appleScript = NSAppleScript(source: script) {
                    appleScript.executeAndReturnError(nil)
                }
            }
        } else if action == "createSampleConfig" {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            let sampleBrainDir = "\(home)/.gemini/antigravity/brain/welcome-demo-agent/.system_generated/logs"
            try? FileManager.default.createDirectory(atPath: sampleBrainDir, withIntermediateDirectories: true, attributes: nil)
            let sampleLogPath = "\(sampleBrainDir)/transcript.jsonl"
            if !FileManager.default.fileExists(atPath: sampleLogPath) {
                let initialJson = "{\"type\":\"USER_INPUT\",\"content\":\"<USER_REQUEST>Khởi động hệ thống Antigravity Monitor thành công!</USER_REQUEST>\",\"status\":\"DONE\"}\n{\"type\":\"PLANNER_RESPONSE\",\"content\":\"Chào bạn! Tôi là Antigravity Bot. Cấu hình máy tính của bạn đã sẵn sàng 100%!\",\"status\":\"DONE\"}\n"
                try? initialJson.write(toFile: sampleLogPath, atomically: true, encoding: .utf8)
            }
            onRefresh?()
        } else if action == "revealBrainInFinder" {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            let targetPath = "\(home)/.gemini/antigravity"
            try? FileManager.default.createDirectory(atPath: targetPath, withIntermediateDirectories: true, attributes: nil)
            let brainUrl = URL(fileURLWithPath: targetPath)
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: brainUrl.path)
        }
    }
}

// MARK: - WebKit Container
struct PlayfulWebView: NSViewRepresentable {
    let url: URL
    @ObservedObject var scanner: AgentScanner
    let bridge = WebKitBridge()

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        bridge.scanner = scanner
        controller.add(bridge, name: "nativeApp")
        config.userContentController = controller
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView
        bridge.onRefresh = { [weak scanner, weak webView] in
            scanner?.refresh {
                DispatchQueue.main.async {
                    if let jsonString = scanner?.toJsonString() {
                        let js = "if (window.onAgentUpdate) { window.onAgentUpdate(\(jsonString)); }"
                        webView?.evaluateJavaScript(js, completionHandler: nil)
                    }
                }
            }
        }

        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let jsonString = scanner.toJsonString() {
            let js = "if (window.onAgentUpdate) { window.onAgentUpdate(\(jsonString)); }"
            nsView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var webView: WKWebView?
    }
}

// MARK: - Live Scanner
class AgentScanner: ObservableObject {
    @Published var agentsJson: [[String: Any]] = []
    private var timer: Timer?

    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func getWorkspaceForAgent(agentId: String) -> String {
        for a in agentsJson {
            if (a["id"] as? String) == agentId, let ws = a["workspacePath"] as? String, !ws.isEmpty {
                return ws
            }
        }
        return FileManager.default.homeDirectoryForCurrentUser.path
    }

    func toJsonString() -> String? {
        let fileManager = FileManager.default
        let home = fileManager.homeDirectoryForCurrentUser.path
        let ideBrainPath = "\(home)/.gemini/antigravity-ide/brain"
        let desktopBrainPath = "\(home)/.gemini/antigravity/brain"
        let geminiDirExists = fileManager.fileExists(atPath: "\(home)/.gemini")
        let ideBrainExists = fileManager.fileExists(atPath: ideBrainPath)
        let desktopBrainExists = fileManager.fileExists(atPath: desktopBrainPath)

        var issues: [String] = []
        if !ideBrainExists && !desktopBrainExists {
            issues.append("Chưa tìm thấy thư mục ~/.gemini/antigravity/brain hoặc ~/.gemini/antigravity-ide/brain")
        }
        if agentsJson.isEmpty && (ideBrainExists || desktopBrainExists) {
            issues.append("Đã có thư mục Antigravity nhưng chưa phát hiện phiên làm việc (conversation) nào trong 18 giờ qua")
        }

        let diagnostic: [String: Any] = [
            "isConfigValid": (ideBrainExists || desktopBrainExists),
            "ideBrainExists": ideBrainExists,
            "desktopBrainExists": desktopBrainExists,
            "geminiDirExists": geminiDirExists,
            "detectedConversations": agentsJson.count,
            "homePath": home,
            "issues": issues,
            "statusMessage": (ideBrainExists || desktopBrainExists) ? "Cấu hình Antigravity hợp lệ! Đã sẵn sàng." : "Chưa phát hiện cấu hình Antigravity trên máy tính này."
        ]

        var totalTokensUsed = 0
        for a in agentsJson {
            totalTokensUsed += (a["tokensEst"] as? Int) ?? 1200
        }
        let maxTokens = 1000000
        let usedPct = min(100, max(0, Int((Double(totalTokensUsed) / Double(maxTokens)) * 100)))
        let remainingPct = max(5, 100 - usedPct)
        let remainingCredits = max(50, 1000 - Int(Double(totalTokensUsed) / 1000.0))

        let userAccount = ProcessInfo.processInfo.environment["ANTIGRAVITY_ACCOUNT"] ?? "\(NSUserName())@local"
        let quota: [String: Any] = [
            "account": userAccount,
            "tier": "Google AI Pro",
            "credits": remainingCredits,
            "remainingPct": remainingPct,
            "usedPct": usedPct,
            "totalTokensUsed": totalTokensUsed,
            "maxTokens": maxTokens,
            "resetTime": "00:00 UTC (Hàng ngày)",
            "rateLimit": "High Priority • Không giới hạn lượt",
            "activeModel": "Gemini 3.8 Flash (High)",
            "models": [
                [
                    "name": "Gemini 3.8 Flash (High)",
                    "provider": "Google DeepMind",
                    "context": "1,000,000 tokens (1M)",
                    "remainingPct": remainingPct,
                    "status": "Active (Mặc định)",
                    "speed": "⚡ Siêu tốc (~120 tps)"
                ],
                [
                    "name": "Claude Sonnet 4.6 (Thinking)",
                    "provider": "Anthropic",
                    "context": "200,000 tokens",
                    "remainingPct": 85,
                    "status": "Khả dụng",
                    "speed": "🧠 Suy luận sâu (Thinking)"
                ],
                [
                    "name": "Claude Opus 4.6 (Thinking)",
                    "provider": "Anthropic",
                    "context": "200,000 tokens",
                    "remainingPct": 80,
                    "status": "Khả dụng",
                    "speed": "🏛️ Thiết kế kiến trúc lớn"
                ],
                [
                    "name": "GPT-OSS 120B (Medium)",
                    "provider": "Open Weights",
                    "context": "128,000 tokens",
                    "remainingPct": 92,
                    "status": "Khả dụng",
                    "speed": "⚙️ Tiêu chuẩn"
                ]
            ]
        ]
        let payload: [String: Any] = [
            "agents": agentsJson,
            "quota": quota,
            "diagnostic": diagnostic
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func refresh(completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let items = self?.scanRealAgents() ?? []
            DispatchQueue.main.async {
                self?.agentsJson = items
                completion?()
            }
        }
    }

    private func scanRealAgents() -> [[String: Any]] {
        var list: [[String: Any]] = []
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let sources = [
            ("IDE", "\(home)/.gemini/antigravity-ide/brain"),
            ("Desktop", "\(home)/.gemini/antigravity/brain")
        ]

        let fileManager = FileManager.default
        let now = Date()

        for (env, basePath) in sources {
            guard let convDirs = try? fileManager.contentsOfDirectory(atPath: basePath) else { continue }
            for cid in convDirs {
                let logPath = "\(basePath)/\(cid)/.system_generated/logs/transcript.jsonl"
                guard fileManager.fileExists(atPath: logPath),
                      let attrs = try? fileManager.attributesOfItem(atPath: logPath),
                      let mdate = attrs[.modificationDate] as? Date else { continue }

                if now.timeIntervalSince(mdate) > 3600 * 18 { continue }

                var steps = 0
                var tokensEst = 1200
                var lastPrompt = ""
                var lastTool = "None"
                var workspacePath = ""
                var model = "Gemini 3.8 Flash (High)"
                var collectedLogs: [String] = []
                var lastType = ""
                var lastStatus = ""
                var lastHasTools = false

                if let content = try? String(contentsOfFile: logPath, encoding: .utf8) {
                    let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
                    steps = lines.count
                    tokensEst = max(1200, Int(Double(content.count) / 3.8))

                    // Parse last line for precise execution state
                    if let lastLine = lines.last,
                       let lastData = lastLine.data(using: .utf8),
                       let lastJson = try? JSONSerialization.jsonObject(with: lastData) as? [String: Any] {
                        lastType = lastJson["type"] as? String ?? ""
                        lastStatus = lastJson["status"] as? String ?? ""
                        if let m = lastJson["model"] as? String, !m.isEmpty {
                            model = m
                        }
                        if let tools = lastJson["tool_calls"] as? [[String: Any]], !tools.isEmpty {
                            lastHasTools = true
                        }
                    }

                    let recentLines = lines.suffix(40)
                    for line in recentLines {
                        guard let data = line.data(using: .utf8),
                              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }

                        let type = json["type"] as? String ?? ""
                        if type == "USER_INPUT" {
                            let rawContent = json["content"] as? String ?? ""
                            if rawContent.contains("Active Document: ") {
                                if let range = rawContent.range(of: "Active Document: ") {
                                    let sub = String(rawContent[range.upperBound...])
                                    let doc = sub.components(separatedBy: " (LANGUAGE")[0].components(separatedBy: "\n")[0].trimmingCharacters(in: .whitespaces)
                                    // Extract repo root dynamically
                                    let comps = doc.components(separatedBy: "/")
                                    if let pIdx = comps.firstIndex(where: { ["projects", "projectAI", "Documents", "Developer", "Workspace", "work", "src"].contains($0) }), pIdx + 1 < comps.count {
                                        workspacePath = comps[0...pIdx+1].joined(separator: "/")
                                    } else if !doc.isEmpty && doc.hasPrefix("/") {
                                        workspacePath = (doc as NSString).deletingLastPathComponent
                                    } else {
                                        workspacePath = "\(home)/Documents"
                                    }
                                }
                            }

                            let text = rawContent
                                .replacingOccurrences(of: "<USER_REQUEST>", with: "")
                                .replacingOccurrences(of: "</USER_REQUEST>", with: "")
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            if !text.isEmpty {
                                lastPrompt = String(text.prefix(80))
                                collectedLogs.append("[USER] \(text.prefix(80))")
                            }
                        } else if type == "PLANNER_RESPONSE" {
                            if let tools = json["tool_calls"] as? [[String: Any]] {
                                for t in tools {
                                    let tname = t["name"] as? String ?? "tool"
                                    lastTool = tname
                                    var argDesc = ""
                                    if let args = t["arguments"] as? [String: Any] {
                                        if let cmd = args["CommandLine"] as? String {
                                            let firstPart = cmd.components(separatedBy: "\n").first ?? cmd
                                            argDesc = String(firstPart.prefix(60))
                                        } else if let summary = args["toolSummary"] as? String {
                                            argDesc = summary
                                        } else if let path = args["Path"] as? String {
                                            argDesc = (path as NSString).lastPathComponent
                                        } else if let query = args["query"] as? String {
                                            argDesc = query
                                        } else if let role = args["Role"] as? String {
                                            argDesc = role
                                        }
                                    }
                                    if !argDesc.isEmpty {
                                        collectedLogs.append("[TOOL] \(tname): \(argDesc)")
                                    } else {
                                        collectedLogs.append("[TOOL] \(tname)")
                                    }
                                }
                            }
                            if let c = json["content"] as? String, !c.isEmpty {
                                let trimmed = c.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty {
                                    collectedLogs.append("[AGENT] \(trimmed.prefix(75))")
                                }
                            }
                            if let st = json["status"] as? String, st == "DONE" {
                                collectedLogs.append("[RESULT] 200 OK (Done)")
                            }
                        } else if type == "RUN_COMMAND" {
                            let cmd = json["CommandLine"] as? String ?? "run_command"
                            let firstPart = cmd.components(separatedBy: "\n").first ?? cmd
                            collectedLogs.append("[CMD] \(firstPart.prefix(60))")
                        }
                    }
                }

                if workspacePath.isEmpty {
                    workspacePath = env == "IDE" ? "\(home)/Documents/projectAI/pango-ai-flowise-source" : "\(home)/Documents/projects/optiflow/optiflow-svc"
                }

                let projectName = (workspacePath as NSString).lastPathComponent
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"

                // Strict Active Determination: Prevent hung/stuck "Processing" states
                let timeDelta = now.timeIntervalSince(mdate)
                var isActivelyRunning = false
                if timeDelta < 90 { // Modified within 90 seconds
                    if lastType == "USER_INPUT" {
                        isActivelyRunning = true
                    } else if lastType == "PLANNER_RESPONSE" {
                        // If PLANNER_RESPONSE has tool_calls, tools are executing.
                        // If no tool_calls, agent provided conversational response to user and is DONE.
                        isActivelyRunning = lastHasTools
                    } else if (lastType == "RUN_COMMAND" || lastType == "GENERIC") && lastStatus == "RUNNING" {
                        isActivelyRunning = timeDelta < 60
                    }
                }
                let isActive = isActivelyRunning

                // Determine room, action, and speech bubble based on real context
                var houseRoom = "office"
                var actionState = "typing"
                var bubbleText = "💻 Code 60 WPM"

                if isActive {
                    houseRoom = "office"
                    actionState = "typing"
                    if lastTool != "None" {
                        bubbleText = "🛠️ \(lastTool)"
                    } else {
                        bubbleText = "⚡ Đang xử lý task"
                    }
                } else if timeDelta < 300 { // Just completed in last 5 mins -> Coffee/Kitchen
                    houseRoom = "kitchen"
                    actionState = "coffee"
                    bubbleText = "☕ Vừa xong task! Thư giãn"
                } else if timeDelta < 1800 { // 5 to 30 mins: Living Lounge
                    let hashVal = abs(cid.hashValue)
                    if hashVal % 2 == 0 {
                        houseRoom = "living"
                        actionState = "relaxing"
                        bubbleText = "🛋️ Chill sofa & Lo-fi TV 📺"
                    } else {
                        houseRoom = "kitchen"
                        actionState = "coffee"
                        bubbleText = "☕ Đang nạp Espresso 🍕"
                    }
                } else { // Inactive > 30 mins: Sleep Pod
                    houseRoom = "bedroom"
                    actionState = "sleeping"
                    bubbleText = "💤 Zzz... Ngủ ngon 0 bug"
                }

                let mainStep = collectedLogs.last ?? (isActive ? "Đang chạy: \(lastPrompt.prefix(40))" : "Hoàn thành")

                // Diverse Character Avatars (Transparent Cutouts)
                let characterAvatars: [(img: String, name: String, role: String)] = [
                    ("./assets/dev_bot.png", "Dev Bot", "Fullstack AI Coder"),
                    ("./assets/deployer_bot.png", "Deployer Bot", "Cloud & CI/CD Ops"),
                    ("./assets/guardian_bot.png", "Guardian Bot", "Security & QA Auditor"),
                    ("./assets/bot_ninja_hacker.png", "Shadow Ninja", "Stealth Refactoring"),
                    ("./assets/bot_chibi_astro.png", "Astro Bot", "Cloud Architecture"),
                    ("./assets/bot_wizard_ai.png", "Wizard AI", "Deep Reasoning & Algo"),
                    ("./assets/bot_mecha_titan.png", "Titan Mech", "High-Throughput Worker"),
                    ("./assets/bot_dino_dev.png", "Dino Junior", "Fast Prototyping"),
                    ("./assets/bot_detective_ai.png", "Sherlock AI", "Root-Cause Bug Hunter"),
                    ("./assets/bot_barista_cafe.png", "Barista Bot", "Performance Optimizer"),
                    ("./assets/bot_pixel_fox.png", "Kitsune Dev", "UI/UX & Mobile"),
                    ("./assets/bot_cyber_punk.png", "Neon Cyberpunk", "Reverse Engineering"),
                    ("./assets/bot_alien_coder.png", "Alien Coder", "Autonomous Specialist"),
                    ("./assets/meo_bo.png", "Mèo Bơ Mascot", "Studio Chief Mascot")
                ]

                var hashVal = 0
                for byte in cid.utf8 { hashVal = (hashVal &* 31) &+ Int(byte) }
                let charIdx = abs(hashVal) % characterAvatars.count
                let assigned = characterAvatars[charIdx]

                var name = assigned.name
                var charType = "dev"
                var avatarImg = assigned.img
                var role = assigned.role
                var dialog = isActive ? "Đang tập trung xử lý tác vụ..." : "Task đã xong, đang nạp năng lượng!"

                let lowerPrompt = lastPrompt.lowercased()
                if lowerPrompt.contains("deploy") || lowerPrompt.contains("cloudflare") {
                    name = "Deployer Bot"
                    charType = "deploy"
                    avatarImg = "./assets/deployer_bot.png"
                    role = "Cloud & CI/CD Ops"
                    dialog = isActive ? "Đang deploy & setup tunnel..." : "Deploy 200 OK thành công!"
                } else if lowerPrompt.contains("commit") || lowerPrompt.contains("review") || lowerPrompt.contains("security") {
                    name = "Guardian Bot"
                    charType = "security"
                    avatarImg = "./assets/guardian_bot.png"
                    role = "Security & QA Auditor"
                    dialog = isActive ? "Đang audit code & security..." : "Đã bảo vệ an toàn codebase!"
                } else if lowerPrompt.contains("bug") || lowerPrompt.contains("fix") || lowerPrompt.contains("error") {
                    name = "Sherlock AI"
                    charType = "security"
                    avatarImg = "./assets/bot_detective_ai.png"
                    role = "Root-Cause Bug Hunter"
                    dialog = isActive ? "Đang truy tìm nguyên nhân gốc..." : "Đã diệt sạch mọi bug tiềm ẩn!"
                } else if lowerPrompt.contains("ui") || lowerPrompt.contains("giao diện") || lowerPrompt.contains("mobile") || lowerPrompt.contains("css") {
                    name = "Kitsune Dev"
                    charType = "dev"
                    avatarImg = "./assets/bot_pixel_fox.png"
                    role = "UI/UX & Mobile Craftsman"
                    dialog = isActive ? "Đang trau chuốt giao diện mượt mà..." : "UI/UX đã chuẩn responsive!"
                } else if lowerPrompt.contains("refactor") || lowerPrompt.contains("clean") {
                    name = "Shadow Ninja"
                    charType = "dev"
                    avatarImg = "./assets/bot_ninja_hacker.png"
                    role = "Stealth Refactoring"
                    dialog = isActive ? "Đang thanh lọc clean code..." : "Codebase gọn gàng, 0 nợ kỹ thuật!"
                }

                let dict: [String: Any] = [
                    "id": cid,
                    "shortId": String(cid.prefix(8)),
                    "name": name,
                    "characterType": charType,
                    "avatarImg": avatarImg,
                    "role": role,
                    "project": projectName,
                    "branch": "main",
                    "workspacePath": workspacePath,
                    "model": model,
                    "dialog": dialog,
                    "env": env,
                    "steps": steps,
                    "tokensEst": tokensEst,
                    "tokensEstFormatted": tokensEst >= 1000 ? "\(tokensEst / 1000)k" : "\(tokensEst)",
                    "contextPct": "\(min(100, max(1, Int(Double(tokensEst) / 1000000.0 * 100.0))))%",
                    "time": timeFormatter.string(from: mdate),
                    "tool": lastTool,
                    "prompt": lastPrompt.isEmpty ? "Đang xử lý tác vụ..." : lastPrompt,
                    "isActive": isActive,
                    "houseRoom": houseRoom,
                    "actionState": actionState,
                    "bubbleText": bubbleText,
                    "mainStep": mainStep,
                    "logs": Array(collectedLogs.suffix(15)),
                    "mtime_raw": mdate.timeIntervalSince1970
                ]
                list.append(dict)
            }
        }

        list.sort { ($0["mtime_raw"] as? Double ?? 0) > ($1["mtime_raw"] as? Double ?? 0) }
        return Array(list.prefix(6))
    }
}

// MARK: - Window Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - App Main
@available(macOS 13.0, *)
@main
struct AntigravityMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var scanner = AgentScanner()

    var htmlUrl: URL {
        if let bundleUrl = Bundle.main.url(forResource: "app", withExtension: "html") {
            return bundleUrl
        }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let localUrl = URL(fileURLWithPath: "\(home)/Documents/projects/antigravity-menubar/app.html")
        return localUrl
    }

    var body: some Scene {
        Window("AntigravityMonitor", id: "main") {
            PlayfulWebView(url: htmlUrl, scanner: scanner)
                .frame(minWidth: 880, idealWidth: 1240, minHeight: 760, idealHeight: 900)
        }
        .windowResizability(.contentSize)
    }
}
