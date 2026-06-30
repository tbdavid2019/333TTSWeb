# 360 TTS Multiverse Hub

這是一個輕量級、美觀且具備高保真語音合成功能的單網頁應用程式（SPA），可用於本地部署或直接託管至 GitHub Pages 上。它整合了 `talk-dev.aitago.tw` 伺服器上的多個 TTS 服務，提供使用者和團隊進行展示與音色測試。

## 🌟 核心功能
- **多模型即時切換**：
  - **IndexTTS (Main) [Port 8001]**：主模型，支援豐富的中文角色預設與上傳音訊複製。
  - **IndexTTS (TW) [Port 8002]**：針對台灣國語腔調與閩南話特別優化的在地口音模型。
  - **CosyVoice 3 [Port 8003]**：阿里開源最新聲音克隆系統，支援預訓練音色（SFT）與零樣本克隆（Zero-Shot，音色複製）。
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
5. 稍等片刻，即可透過生成的 `https://<您的 GitHub 帳號>.github.io/360TTSWeb/` 開啟服務！

---

## 🔒 瀏覽器安全與 HTTPS 反向代理（開箱即用）

由於 GitHub Pages 強制使用 **HTTPS** 安全連接，為了避免瀏覽器的 **混合內容 (Mixed Content) 封鎖** 與 **CORS 限制**，我們已經在伺服器上透過 Nginx 配置了安全反向代理與 Let's Encrypt SSL 憑證：

- **反向代理域名**：`https://tts.create360.ai`
- **安全路徑對照**：
  - `https://tts.create360.ai/8001/` ➔ `http://127.0.0.1:8001/` (IndexTTS Main)
  - `https://tts.create360.ai/8002/` ➔ `http://127.0.0.1:8002/` (IndexTTS TW)
  - `https://tts.create360.ai/8003/` ➔ `http://127.0.0.1:8003/` (CosyVoice 3)
  - `https://tts.create360.ai/8005/` ➔ `http://127.0.0.1:8005/` (Qwen TTS)

**自動適應邏輯**：
網頁 [index.html](file:///Users/david/Documents/git-360/360TTSWeb/index.html) 具備自動感應功能。在 HTTPS 網頁環境下開啟時，預設 API 終端點會**自動切換**為上述 HTTPS 安全代理網址，不再需要手動修改設定，直接開箱即可通暢檢測為「線上」並正常生成語音！

---

## 🎨 高級設計與視覺體驗
- **雙主題系統**：支援一鍵切換**深色（Catppuccin Frappé）**與**淺色（Catppuccin Latte）**主題，針對長時間閱讀與眼睛疲勞特別優化，調色盤柔和且具備高對比。
- **懸浮固定導覽列**：頂部 Navigation Bar 採用 `backdrop-filter: blur(16px)` 的懸浮毛玻璃效果，提供極致流暢的視覺回饋。
- **進階播放軌與進度拉條**：音波圖除了展示聲學指紋，還包含實時播放進度直條與發光滑塊（Scrubber Dot），支援點擊任意處進行音訊快轉。
- **使用頻率優先佈局**：遵循 UI 設計的使用頻率原則，將「輸入欲合成之文字」及操作按鈕移至最顯眼的最上方，降低使用者操作的視覺負擔。

---

## 📅 更新日誌
詳細的開發歷程與變更內容，請參閱 [CHANGELOG.md](file:///Users/david/Documents/git-360/360TTSWeb/CHANGELOG.md)。

## 📄 授權條款
本專案採用 **GNU Affero General Public License v3.0 (AGPL-3.0)** 條款授權開源。
