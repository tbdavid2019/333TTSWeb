# 333 Taiwanese TTS Hub

這是一個單頁語音工作台，可用於本地部署或直接託管至 GitHub Pages。它整合多個 TTS 服務，方便快速試聽、比較模型差異、展示台語與國語語音效果。

## 🌟 核心功能
- **多模型即時切換**：
  - **IndexTTS (Main) [Port 8001]**：主模型，支援豐富的中文角色預設與上傳音訊複製。
  - **IndexTTS (TW) [Port 8002]**：針對台灣國語腔調與閩南話特別優化的在地口音模型。
  - **CosyVoice 3 [Port 8003]**：阿里開源最新聲音克隆系統，支援預訓練音色（SFT）與零樣本克隆（Zero-Shot，音色複製）。
  - **CosyVoice 2 [Port 8006]**：教育部台語資料路線，節奏穩定、抑揚清楚，適合標準台語朗讀。
  - **Qwen TTS [Port 8005]**：基於 1.7B 參數量的大型語音合成模型，支援中、英、日、韓、法、德等十餘種語言的混讀。
- **極速聲音克隆**：
  - **IndexTTS 克隆 (`/tts_upload`)**：支援透過上傳 3-10 秒參考音訊並調整隨機種子（Seed）進行克隆。
  - **CosyVoice 3 零樣本克隆 (`Zero-Shot`)**：提供音檔上傳與參考文字檔（Prompt Text）欄位，複製效果逼真自然。
- **Canvas 音頻波形圖**：
  - 將二進制音訊資料解碼，透過 `<canvas>` 繪製精美且具備互動性的柱狀音軌。
  - 支援在波形上點擊調整進度（Seek），並隨播放進度呈現漸變紫色與青色的填充狀態。
- **本地合成紀錄**：
  - 基於瀏覽器 **IndexedDB**（資料庫名稱 `360TTSHubDB`）進行本地持久化儲存。
  - 包含生成文字、時間、選用模型、聲音名稱及音訊 Blob。支援重播、單獨下載與管理刪除，安全且不佔用伺服器資源。
- **可配置設定**：
  - 支援在介面中動態設定 API 連線主機（Host）以及自訂各端口的 URL。
  - 提供 CORS 代理欄位，幫助繞過部分網絡與瀏覽器安全阻擋。

## 🚀 部署至 GitHub Pages
此專案沒有任何複雜的打包工具或編譯流程。您只需要：
1. 將此儲存庫 Clone 至您的本地或 Fork 專案。
2. 進入儲存庫的 **Settings** -> **Pages**。
3. 將 Build and deployment 的 Source 設定為 `Deploy from a branch`。
4. 選擇 `main` 分支的 `/ (root)`，並點擊 Save。
5. 稍等片刻，即可透過生成的 `https://<您的 GitHub 帳號>.github.io/333TTSWeb/` 開啟服務！

---

## 🔒 瀏覽器安全與 HTTPS 反向代理

如果你把前端掛在 HTTPS 網域下，而後端 TTS 服務仍是 HTTP port 服務，瀏覽器通常會遇到 **Mixed Content** 與 **CORS** 問題。此專案支援以反向代理方式處理：

- **反向代理域名**：`https://tts.create360.ai`
- **安全路徑對照**：
  - `https://tts.create360.ai/8001/` ➔ `http://127.0.0.1:8001/` (IndexTTS Main)
  - `https://tts.create360.ai/8002/` ➔ `http://127.0.0.1:8002/` (IndexTTS TW)
  - `https://tts.create360.ai/8003/` ➔ `http://127.0.0.1:8003/` (CosyVoice 3)
  - `https://tts.create360.ai/8006/` ➔ `http://127.0.0.1:8006/` (CosyVoice 2)
  - `https://tts.create360.ai/8005/` ➔ `http://127.0.0.1:8005/` (Qwen TTS)

**自動適應邏輯**：
網頁 [index.html](/Users/david/Documents/git/tbdavid2019/333TTSWeb/index.html) 會在 HTTPS 的真實網域環境下優先使用同網域 `/8001`、`/8002`、`/8003`、`/8005`、`/8006` 路徑；若是本機或未配置代理的情況，則回退到 `http://<host>:port`。

---

## 🎨 介面特點
- **雙主題系統**：支援一鍵切換明暗主題。
- **懸浮固定導覽列**：頂部 Navigation Bar 採用 `backdrop-filter: blur(16px)` 的懸浮效果。
- **進階播放軌與進度拉條**：音波圖除了展示聲學指紋，還包含實時播放進度直條與發光滑塊（Scrubber Dot），支援點擊任意處進行音訊快轉。
- **個人工作台式排版**：首頁加上簡短導引與說明卡，適合展示與自用。

---

## 📅 更新日誌
詳細的開發歷程與變更內容，請參閱 [CHANGELOG.md](/Users/david/Documents/git/tbdavid2019/333TTSWeb/CHANGELOG.md)。

## 📄 授權條款
本專案採用 **GNU Affero General Public License v3.0 (AGPL-3.0)** 條款授權開源。
