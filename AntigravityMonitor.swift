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
    private var lastObservedAccount: String? = nil

    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    private func getActiveGoogleAccount() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let accountsUrl = URL(fileURLWithPath: "\(home)/.gemini/google_accounts.json")
        if let data = try? Data(contentsOf: accountsUrl),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let active = json["active"] as? String, !active.isEmpty {
            return active
        }
        return ProcessInfo.processInfo.environment["ANTIGRAVITY_ACCOUNT"] ?? "\(NSUserName())@gmail.com"
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
            issues.append("Missing ~/.gemini/antigravity/brain or ~/.gemini/antigravity-ide/brain")
        }
        if agentsJson.isEmpty && (ideBrainExists || desktopBrainExists) {
            issues.append("Antigravity engine detected but no active conversation in the last 18 hours")
        }

        let diagnostic: [String: Any] = [
            "isConfigValid": (ideBrainExists || desktopBrainExists),
            "ideBrainExists": ideBrainExists,
            "desktopBrainExists": desktopBrainExists,
            "geminiDirExists": geminiDirExists,
            "detectedConversations": agentsJson.count,
            "homePath": home,
            "issues": issues,
            "statusMessage": (ideBrainExists || desktopBrainExists) ? "Valid Antigravity engine active and ready." : "No Antigravity brain configuration found on this machine."
        ]

        var totalTokensUsed = 0
        for a in agentsJson {
            totalTokensUsed += (a["tokensEst"] as? Int) ?? 1200
        }
        let maxTokens = 1000000
        let usedPct = min(100, max(0, Int((Double(totalTokensUsed) / Double(maxTokens)) * 100)))
        let remainingPct = max(5, 100 - usedPct)
        let remainingCredits = max(50, 1000 - Int(Double(totalTokensUsed) / 1000.0))

        let userAccount = getActiveGoogleAccount()
        var accountChanged = false
        if let last = lastObservedAccount, last != userAccount {
            accountChanged = true
        }
        lastObservedAccount = userAccount

        let quota: [String: Any] = [
            "account": userAccount,
            "accountChanged": accountChanged,
            "tier": "Google AI Pro",
            "credits": remainingCredits,
            "remainingPct": remainingPct,
            "usedPct": usedPct,
            "totalTokensUsed": totalTokensUsed,
            "maxTokens": maxTokens,
            "resetTime": "00:00 UTC (Daily)",
            "rateLimit": "High Priority • Unlimited speed",
            "activeModel": "Gemini 3.8 Flash (High)",
            "models": [
                [
                    "name": "Gemini 3.8 Flash (High)",
                    "provider": "Google DeepMind",
                    "context": "1,000,000 tokens (1M)",
                    "remainingPct": remainingPct,
                    "status": "Active (Default)",
                    "speed": "⚡ Ultra Fast (~120 tps)"
                ],
                [
                    "name": "Claude Sonnet 4.6 (Thinking)",
                    "provider": "Anthropic",
                    "context": "200,000 tokens",
                    "remainingPct": 85,
                    "status": "Available",
                    "speed": "🧠 Deep Reasoning (Thinking)"
                ],
                [
                    "name": "Claude Opus 4.6 (Thinking)",
                    "provider": "Anthropic",
                    "context": "200,000 tokens",
                    "remainingPct": 80,
                    "status": "Available",
                    "speed": "🏛️ System Architecture"
                ],
                [
                    "name": "GPT-OSS 120B (Medium)",
                    "provider": "Open Weights",
                    "context": "128,000 tokens",
                    "remainingPct": 92,
                    "status": "Available",
                    "speed": "⚙️ Standard"
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

        // Phase 1: Pre-scan all conversations to detect subagents created via invoke_subagent
        struct SubagentMeta {
            var parentId: String
            var role: String
            var prompt: String
            var typeName: String
        }
        var subagentRegistry: [String: SubagentMeta] = [:]

        for (_, basePath) in sources {
            guard let convDirs = try? fileManager.contentsOfDirectory(atPath: basePath) else { continue }
            for cid in convDirs {
                let logPath = "\(basePath)/\(cid)/.system_generated/logs/transcript.jsonl"
                guard fileManager.fileExists(atPath: logPath),
                      let attrs = try? fileManager.attributesOfItem(atPath: logPath),
                      let mdate = attrs[.modificationDate] as? Date,
                      now.timeIntervalSince(mdate) <= 3600 * 36 else { continue }

                guard let content = try? String(contentsOfFile: logPath, encoding: .utf8) else { continue }
                if content.contains("invoke_subagent") {
                    let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
                    for (idx, line) in lines.enumerated() {
                        if line.contains("invoke_subagent"),
                           let data = line.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let toolCalls = json["tool_calls"] as? [[String: Any]] {
                            for tc in toolCalls {
                                if (tc["name"] as? String) == "invoke_subagent" {
                                    var argsDict: [String: Any] = [:]
                                    if let a = tc["args"] as? [String: Any] { argsDict = a }
                                    else if let a = tc["arguments"] as? [String: Any] { argsDict = a }
                                    else if let aStr = tc["args"] as? String,
                                            let aData = aStr.data(using: .utf8),
                                            let aObj = try? JSONSerialization.jsonObject(with: aData) as? [String: Any] {
                                        argsDict = aObj
                                    }

                                    let role = (argsDict["Role"] as? String ?? "").replacingOccurrences(of: "\"", with: "")
                                    let prompt = (argsDict["Prompt"] as? String ?? "").replacingOccurrences(of: "\"", with: "")
                                    let typeName = (argsDict["TypeName"] as? String ?? "specialist").replacingOccurrences(of: "\"", with: "")

                                    // Check next step for conversationId
                                    if idx + 1 < lines.count {
                                        let nextLine = lines[idx + 1]
                                        var contentToSearch = nextLine
                                        if let nextData = nextLine.data(using: .utf8),
                                           let nextJson = try? JSONSerialization.jsonObject(with: nextData) as? [String: Any],
                                           let contentStr = nextJson["content"] as? String {
                                            contentToSearch = contentStr
                                        }

                                        if let range = contentToSearch.range(of: "\"conversationId\":\\s*\"([a-f0-9\\-]+)\"", options: .regularExpression) {
                                            let matched = String(contentToSearch[range])
                                            let parts = matched.components(separatedBy: "\"")
                                            if parts.count >= 4 {
                                                let subCid = parts[3]
                                                subagentRegistry[subCid] = SubagentMeta(parentId: cid, role: role, prompt: prompt, typeName: typeName)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Phase 2: Full parsing of each active or recent conversation
        for (env, basePath) in sources {
            guard let convDirs = try? fileManager.contentsOfDirectory(atPath: basePath) else { continue }
            for cid in convDirs {
                let logPath = "\(basePath)/\(cid)/.system_generated/logs/transcript.jsonl"
                guard fileManager.fileExists(atPath: logPath),
                      let attrs = try? fileManager.attributesOfItem(atPath: logPath),
                      let mdate = attrs[.modificationDate] as? Date else { continue }

                let timeDelta = now.timeIntervalSince(mdate)
                if timeDelta > 3600 * 36 { continue }

                var steps = 0
                var tokensEst = 1200
                var lastPrompt = ""
                var lastTool = "None"
                var workspacePath = ""
                var model = "Gemini 3.8 Flash (High)"
                var collectedLogs: [String] = []
                var lastType = ""
                var lastContent = ""
                var lastHasTools = false
                var hasSentMessage = false

                var isSubagent = subagentRegistry[cid] != nil
                var parentId = subagentRegistry[cid]?.parentId
                let subRole = subagentRegistry[cid]?.role ?? ""
                if let p = subagentRegistry[cid]?.prompt, !p.isEmpty {
                    lastPrompt = p
                }

                if let content = try? String(contentsOfFile: logPath, encoding: .utf8) {
                    let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
                    steps = lines.count
                    tokensEst = max(1200, Int(Double(content.count) / 3.8))

                    // Inspect first step for system message
                    if let firstLine = lines.first,
                       let firstData = firstLine.data(using: .utf8),
                       let firstJson = try? JSONSerialization.jsonObject(with: firstData) as? [String: Any] {
                        if (firstJson["type"] as? String) == "SYSTEM_MESSAGE" {
                            let sysContent = firstJson["content"] as? String ?? ""
                            if sysContent.contains("sender=") {
                                isSubagent = true
                                if parentId == nil, let r = sysContent.range(of: "sender=([a-f0-9\\-]+)", options: .regularExpression) {
                                    let sub = String(sysContent[r]).replacingOccurrences(of: "sender=", with: "")
                                    parentId = sub
                                }
                                if lastPrompt.isEmpty, let r = sysContent.range(of: "content=(.+)", options: [.regularExpression, .caseInsensitive]) {
                                    let sub = String(sysContent[r]).replacingOccurrences(of: "content=", with: "")
                                    lastPrompt = sub
                                }
                            }
                        }
                    }

                    // Parse last line for precise execution state
                    if let lastLine = lines.last,
                       let lastData = lastLine.data(using: .utf8),
                       let lastJson = try? JSONSerialization.jsonObject(with: lastData) as? [String: Any] {
                        lastType = lastJson["type"] as? String ?? ""
                        lastContent = lastJson["content"] as? String ?? ""
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
                                if !isSubagent {
                                    lastPrompt = String(text.prefix(120))
                                }
                                collectedLogs.append("[USER] \(text.prefix(80))")
                            }
                        } else if type == "PLANNER_RESPONSE" {
                            if let tools = json["tool_calls"] as? [[String: Any]] {
                                for t in tools {
                                    let tname = t["name"] as? String ?? "tool"
                                    lastTool = tname

                                    var args: [String: Any] = [:]
                                    if let a = t["args"] as? [String: Any] { args = a }
                                    else if let a = t["arguments"] as? [String: Any] { args = a }
                                    else if let aStr = t["args"] as? String,
                                            let aData = aStr.data(using: .utf8),
                                            let aObj = try? JSONSerialization.jsonObject(with: aData) as? [String: Any] {
                                        args = aObj
                                    }

                                    var argDesc = ""
                                    if let summary = args["toolSummary"] as? String {
                                        argDesc = summary
                                    } else if let action = args["toolAction"] as? String {
                                        argDesc = action
                                    } else if let img = args["ImageName"] as? String {
                                        argDesc = "Generate image \(img)"
                                    } else if let cmd = args["CommandLine"] as? String {
                                        let firstPart = cmd.components(separatedBy: "\n").first ?? cmd
                                        argDesc = String(firstPart.prefix(60))
                                    } else if let path = args["Path"] as? String {
                                        argDesc = (path as NSString).lastPathComponent
                                    } else if let role = args["Role"] as? String {
                                        argDesc = "Invoke subagent \(role)"
                                    } else if let query = args["query"] as? String {
                                        argDesc = query
                                    }

                                    if tname == "send_message" {
                                        hasSentMessage = true
                                        argDesc = "Report complete to Main Agent"
                                    }

                                    argDesc = argDesc.replacingOccurrences(of: "\"", with: "")
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
                        } else if type == "GENERIC" {
                            if let c = json["content"] as? String, !c.isEmpty {
                                let firstLine = c.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n").first ?? ""
                                if !firstLine.isEmpty && !firstLine.contains("Created At:") {
                                    collectedLogs.append("[RESULT] \(firstLine.prefix(60))")
                                }
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

                // Robust Active Determination for Main Agent & Subagents
                let activeToolTypes: Set<String> = [
                    "USER_INPUT", "RUN_COMMAND", "GREP_SEARCH", "VIEW_FILE", "READ_URL_CONTENT",
                    "SEARCH_WEB", "GENERATE_IMAGE", "EDIT_FILE", "WRITE_FILE", "GENERIC",
                    "CODE_ACTION", "INVOKE_SUBAGENT", "BROWSER_SUBAGENT", "ASK_QUESTION"
                ]

                var isActive = false
                if isSubagent {
                    // Subagent is actively running until send_message is completed (10 min activity window)
                    isActive = (timeDelta < 600) && !hasSentMessage
                } else {
                    // Main agent: actively running if executing tools or responding
                    if lastHasTools || activeToolTypes.contains(lastType) {
                        isActive = (timeDelta < 600)
                    } else if lastType == "PLANNER_RESPONSE" && !lastContent.isEmpty {
                        // Conversational final reply is active while recently updated (< 90s)
                        isActive = (timeDelta < 90)
                    } else {
                        isActive = (timeDelta < 300)
                    }
                }

                // Determine house room & action state
                var houseRoom = "office"
                var actionState = "typing"
                var bubbleText = isSubagent ? "🎨 Processing subagent task" : "💻 Code 60 WPM"

                if isActive {
                    houseRoom = "office"
                    actionState = "typing"
                    if lastTool != "None" {
                        bubbleText = "🛠️ \(lastTool)"
                    } else {
                        bubbleText = isSubagent ? "⚡ Processing subagent task" : "⚡ Executing task"
                    }
                } else if timeDelta < 600 { // Last 10 mins: Kitchen Cafe
                    houseRoom = "kitchen"
                    actionState = "coffee"
                    bubbleText = "☕ Task finished! Break time"
                } else if timeDelta < 2400 { // 10 to 40 mins: Living Lounge
                    houseRoom = "living"
                    actionState = "relaxing"
                    bubbleText = "🛋️ Chill sofa & Lo-fi TV 📺"
                } else { // Inactive > 40 mins: Sleep Pod
                    houseRoom = "bedroom"
                    actionState = "sleeping"
                    bubbleText = "💤 Zzz... Sleeping zero bug"
                }

                let mainStep = collectedLogs.last ?? (isActive ? "Running: \(lastPrompt.prefix(40))" : "Completed")

                // Identity & Role Resolution
                var name = ""
                var charType = "dev"
                var avatarImg = "./assets/dev_bot.png"
                var role = "Autonomous Specialist"

                if isSubagent {
                    name = !subRole.isEmpty ? subRole : "Subagent (\(cid.prefix(6)))"
                    role = "Subagent • \(subagentRegistry[cid]?.typeName ?? "Specialist")"
                    charType = "dev"

                    let lowerRole = subRole.lowercased()
                    if lowerRole.contains("asset") || lowerRole.contains("artist") || lowerRole.contains("image") {
                        avatarImg = "./assets/bot_wizard_ai.png"
                        if lowerRole.contains("batch 2") {
                            avatarImg = "./assets/bot_chibi_astro.png"
                        }
                    } else if lowerRole.contains("environment") || lowerRole.contains("studio") {
                        avatarImg = "./assets/bot_barista_cafe.png"
                    } else if lowerRole.contains("security") || lowerRole.contains("qa") || lowerRole.contains("audit") {
                        avatarImg = "./assets/guardian_bot.png"
                        charType = "security"
                    } else {
                        avatarImg = "./assets/bot_pixel_fox.png"
                    }
                } else {
                    if cid.hasPrefix("563099") {
                        name = "Main Agent (Kitsune Dev)"
                        role = "Lead Autonomous Coder"
                        avatarImg = "./assets/bot_pixel_fox.png"
                    } else {
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
                        let assigned = characterAvatars[abs(hashVal) % characterAvatars.count]
                        name = assigned.name
                        role = assigned.role
                        avatarImg = assigned.img
                    }
                }

                let dialog = isActive 
                    ? (isSubagent ? "Accelerating subagent task execution for Main Agent..." : "Focused on executing autonomous task...") 
                    : (isSubagent ? "Branch task completed and reported back to Main Agent!" : "Task completed, taking a break!")

                let dict: [String: Any] = [
                    "id": cid,
                    "shortId": String(cid.prefix(8)),
                    "name": name,
                    "characterType": charType,
                    "avatarImg": avatarImg,
                    "role": role,
                    "isSubagent": isSubagent,
                    "parentId": parentId ?? "",
                    "parentShortId": String((parentId ?? "").prefix(8)),
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
                    "prompt": lastPrompt.isEmpty ? "Executing autonomous task..." : lastPrompt,
                    "isActive": isActive,
                    "houseRoom": houseRoom,
                    "actionState": actionState,
                    "bubbleText": bubbleText,
                    "mainStep": mainStep,
                    "logs": Array(collectedLogs.suffix(20)),
                    "mtime_raw": mdate.timeIntervalSince1970
                ]
                list.append(dict)
            }
        }

        // Active agents first, then sort by most recent mtime
        list.sort {
            let active0 = ($0["isActive"] as? Bool) == true ? 1 : 0
            let active1 = ($1["isActive"] as? Bool) == true ? 1 : 0
            if active0 != active1 { return active0 > active1 }
            return ($0["mtime_raw"] as? Double ?? 0) > ($1["mtime_raw"] as? Double ?? 0)
        }
        return Array(list.prefix(20))
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
