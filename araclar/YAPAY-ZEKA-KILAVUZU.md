# Yerel ve Ücretsiz Yapay Zekâ ile C Kodlama Kılavuzu

Son güncelleme: 2026-09-27

Bu kılavuz, Linux Mint'te OpenCode'u ücretsiz bulut modellerine ve yerel modellere bağlayıp C kodu yazdırmayı anlatır. Ayarlar 16 GB RAM ve GTX 860M'li bir dizüstüne göre seçildi; asıl iş için ücretsiz bulut modelleri, internetsiz küçük işler için yerel modeller önerilir.

## Hızlı başlangıç

Kurulum betiği `opencode-kurulum.sh` bu klasörde durur ve her şeyi tek komutla yapar: paketleri, OpenCode'u, seçtiğin sağlayıcıları ve yerel modelleri kurar.

1. Depoyu çek ve betiği çalıştır. Menüde en azından `2` (NVIDIA) ve `3` (Gemini) seç; yerel yedek istersen `10` (Ollama) ekle.

   ```bash
   git pull
   bash araclar/opencode-kurulum.sh
   ```

2. Anahtarları iste: NVIDIA için build.nvidia.com, Gemini için aistudio.google.com. Betik anahtarları ekrana basmaz, yalnız `~/.local/share/opencode/auth.json` dosyasına (izin 600) yazar.
3. Yeni bir terminal aç ya da `source ~/.bashrc` çalıştır.
4. Proje klasörüne geç ve OpenCode'u başlat:

   ```bash
   cd ~/projem
   opencode
   ```

5. İlk açılışta `/init` yaz; OpenCode projeyi tarar ve `AGENTS.md` oluşturur. Sonra ilk görevi ver: *"@src/main.c içindeki okuma döngüsünü fgets ile güvenli hale getir, meson ile derlendiğini kontrol et"*.

Tek bir parçayı ayrıca kurmak için bayraklar:

| Komut | Ne kurar |
| --- | --- |
| `bash araclar/opencode-kurulum.sh --ollama` | Ollama ve yerel C modelleri |
| `bash araclar/opencode-kurulum.sh --llamacpp` | llama.cpp (Vulkan) ve bir model servisi |
| `bash araclar/opencode-kurulum.sh --lmstudio` | LM Studio uygulaması |
| `bash araclar/opencode-kurulum.sh --jan` | Jan uygulaması |
| `bash araclar/opencode-kurulum.sh --esitle` | Çalışan yerel sunuculardaki modelleri OpenCode'a ekler |

## Ücretsiz bulut sağlayıcıları

NVIDIA NIM ana sağlayıcı olarak yeter; günlük sınır dolunca OpenCode'da `/models` ile bir sonrakine geç. NVIDIA'da Claude modelleri yoktur; gerçek Claude yalnız Anthropic'ten, ücretle alınır.

| Menü | Sağlayıcı | Anahtar adresi | Ücretsiz sınır (yaklaşık) |
| --- | --- | --- | --- |
| 2 | NVIDIA NIM | build.nvidia.com | Dakikada ~40 istek, süre sınırı yok |
| 3 | Google Gemini | aistudio.google.com/apikey | Flash'ta günde ~250 istek |
| 5 | OpenRouter | openrouter.ai/keys | Kredi yüklenmemişse günde 50 istek |
| 1 | OpenCode Zen | opencode.ai/zen | Birkaç ücretsiz model, liste sık değişir |
| 4 | Groq | console.groq.com/keys | Dakikada 30 istek, token sınırı düşük |
| 6 | Mistral | console.mistral.ai | Ücretsiz "Experiment" planı |
| 8 | Hugging Face | huggingface.co/settings/tokens | Aylık küçük kredi |
| 7 | Cerebras | cloud.cerebras.ai | Temmuz 2026'dan beri kart isteyen deneme |
| 9 | GitHub Copilot | Tarayıcıdan giriş | Copilot Free planı |
| 11 | Anthropic Claude | console.anthropic.com | Ücretli |

Ücretsiz sınırlar sık değişir; betik bu yüzden NVIDIA ve OpenRouter'da model listesini her seferinde canlı çeker. OpenRouter'da yalnız şu an ücretsiz ve araç çağırabilen modeller gösterilir.

## Yerel çalıştırıcılar

Dördü de aynı modelleri çalıştırır; kalite değil, kullanım kolaylığı ve hız değişir. 16 GB RAM'de aynı anda yalnız birini çalıştır.

| Çalıştırıcı | Arayüz | OpenCode adresi | Ne zaman seç |
| --- | --- | --- | --- |
| Ollama | Terminal | `http://127.0.0.1:11434/v1` | Varsayılan seçim; model indirme ve değiştirme en kolayı |
| llama.cpp | Terminal (servis) | `http://127.0.0.1:8080/v1` | En hafifi; ekran kartını Vulkan ile kullanır, eski kartta daha hızlı olabilir |
| LM Studio | Grafik | `http://127.0.0.1:1234/v1` | Modelleri pencereden arayıp denemek istersen |
| Jan | Grafik | `http://127.0.0.1:1337/v1` | Açık kaynak, ChatGPT benzeri sohbet penceresi istersen |

LM Studio ve Jan'da modeli uygulamanın içinden indirip sunucuyu başlatman gerekir; ardından `bash araclar/opencode-kurulum.sh --esitle` modelleri OpenCode'a ekler. Jan'da sunucuyu başlatmadan önce bir API anahtarı belirle.

Durdurmak için: Ollama `ollama stop <model>`, llama.cpp `systemctl --user stop llama-server`.

## C için model sıralaması

En iyi ücretsiz seçenek NVIDIA'daki Kimi, DeepSeek V4 ya da GLM'dir; en iyi yerel model `qwen2.5-coder:7b`, ama bulut seviyesinin çok gerisindedir. C'ye özel güvenilir bir kıyaslama yok: sıralama genel kodlama testlerine (SWE-bench, HumanEval) dayanan bir değerlendirmedir.

### Bulut (en iyiden en kötüye)

| Sıra | Model | Nereden | Ücret | Dayanak |
| --- | --- | --- | --- | --- |
| 1 | Claude (Fable, Opus, Sonnet) | Anthropic | Ücretli | Fable 5: SWE-bench Verified %95 |
| 2 | Kimi (K3, K2.x) | NVIDIA, OpenRouter | Ücretsiz | K3: SWE-bench Verified %93.4 |
| 3 | DeepSeek V4 | NVIDIA, OpenCode Zen | Ücretsiz | V4 Pro: SWE-bench Verified %80.6 |
| 4 | GLM-5.x | NVIDIA | Ücretsiz | SWE-bench Pro'da açık modellerin başında (%62.1) |
| 5 | Qwen3-Coder, Qwen3.6 | NVIDIA, OpenRouter | Ücretsiz | Kodlamaya özel, güçlü |
| 6 | MiniMax M2.5 | NVIDIA, OpenCode Zen | Ücretsiz | SWE-bench Verified %75.8 |
| 7 | Gemini Flash | Google | Ücretsiz katman | İyi; ücretsiz katmanda Pro yok |
| 8 | Devstral, Codestral | Mistral | Ücretsiz plan | Orta seviye |
| 9 | Groq modelleri | Groq | Ücretsiz | Çok hızlı ama küçük modeller |
| 10 | OpenRouter `:free` | OpenRouter | Ücretsiz | O gün hangi modelin ücretsiz olduğuna bağlı |

### Yerel (16 GB RAM + GTX 860M)

| Sıra | Model | Boyut | Kod kalitesi | OpenCode ajanı için | Hız |
| --- | --- | --- | --- | --- | --- |
| 1 | `qwen2.5-coder:7b` | ~4.7 GB | HumanEval %88.4 | İyi | Yavaş |
| 2 | `deepseek-coder-v2:16b` | ~9 GB | HumanEval %81.1 | Araç çağırması muhtemelen yok | Orta, RAM'i zorlar |
| 3 | `qwen3:4b` | ~2.5 GB | İyi | En iyi küçük seçenek | Orta |
| 4 | `qwen2.5-coder:3b` | ~1.9 GB | Boyutuna göre güçlü | Orta | Hızlı |
| 5 | `phi4-mini` | ~2.5 GB | HumanEval %74.4 | Orta | Orta |
| 6 | `qwen2.5-coder:1.5b` | ~1 GB | Basit fonksiyonlarda yeterli | Zayıf | Çok hızlı |
| 7 | `granite3.3:2b` | ~1.5 GB | Küçükler arasında ikinci grup | Zayıf | Çok hızlı |
| 8 | `llama3.2:3b` | ~2 GB | Genel model, kodda zayıf | Zayıf | Hızlı |
| 9 | `deepseek-coder:1.3b` | ~0.8 GB | Eski ve çok küçük | Yok | Çok hızlı |

`codegemma:2b` ve `starcoder2:3b` yalnız editörde satır tamamlama içindir (ör. Continue eklentisi); sohbet ya da ajan olarak kullanılamaz. Betiğin C testi, seçtiğin modelin senin makinende `gcc -Wall -Wextra` ile derlenen kod yazıp yazamadığını ölçer.

## OpenCode'da günlük kullanım

İyi sonuç için modele dosyayı, standardı, derleme komutunu ve kontrol ölçütünü söyle; önce plan modunda iste, beğenince build moduna geç.

| Komut | Ne yapar |
| --- | --- |
| `/init` | Projeyi tarar, `AGENTS.md` oluşturur (bir kez) |
| `/models` | Sağlayıcı ve model değiştirir |
| `/connect` | Sonradan yeni bir sağlayıcı anahtarı ekler |
| `Tab` | plan (yalnız önerir) ↔ build (dosyaları değiştirir) |
| `@dosya.c` | Dosyayı bağlama ekler |
| `opencode run "..."` | Arayüz açmadan tek görev çalıştırır |
| `opencode models` | Kullanılabilir tüm modelleri listeler |

İyi C istemi örnekleri:

- *"@src/liste.c içine C11 ile tek yönlü bağlı liste için `liste_ters_cevir` fonksiyonu yaz. `malloc` hatasını kontrol et, bellek sızıntısı bırakma. `gcc -std=c11 -Wall -Wextra` uyarısız derlenmeli."*
- *"@src/parser.c dosyasını oku, olası tampon taşmalarını listele. Değişiklik yapma, yalnız satır numarası ve nedenini yaz."* (plan modu)
- *"`meson compile -C build` şu hatayı veriyor: [hatayı yapıştır]. Nedenini açıkla ve en küçük düzeltmeyi yap."*
- *"@src/window.c içine GTK4 ile bir Ayarlar butonu ekle, tıklayınca AdwPreferencesDialog açsın. Deprecated API kullanma."*

Yerel küçük modellere tek dosya ve tek fonksiyon ver; çok dosyalı işleri bulut modellerine bırak. Değişiklikten sonra kodu her zaman kendin derle ve çalıştır.

## Donanım ayarları (GTX 860M, 16 GB RAM)

GTX 860M'in 2 ya da 4 GB belleği modelin küçük bir kısmını alır; model büyük ölçüde işlemci ve RAM üzerinde çalışır. Bu yüzden yerel modeller yavaştır ve OpenCode'un ajan modu için bulut önerilir.

Önce kartın hangi sürüm olduğunu kontrol et:

```bash
nvidia-smi --query-gpu=name,memory.total,driver_version,compute_cap --format=csv
```

| Kontrol | Gereken | Seninki |
| --- | --- | --- |
| NVIDIA sürücüsü | 570 veya yenisi (compute 5.0–6.2 kartlar için) | 580.178.04, uygun |
| Compute | 5.0 (Maxwell) → Ollama kartı kullanır; 3.0 (Kepler) → yalnız işlemci | Komutla kontrol et |
| Bağlam | En az 16K token; OpenCode'un talimatları 4K'ya sığmaz | Betik 16384 ayarlar |

Betik Ollama servisine şu ayarları yazar (`/etc/systemd/system/ollama.service.d/faw-ayarlar.conf`):

- `OLLAMA_CONTEXT_LENGTH=16384`: varsayılan 4096 bağlam OpenCode'un isteğini sessizce keser.
- `OLLAMA_NUM_PARALLEL=1` ve `OLLAMA_MAX_LOADED_MODELS=1`: RAM'i korur.
- `OLLAMA_KEEP_ALIVE=30m`: model her istekte yeniden yüklenmez.

llama.cpp'de ekran kartına yüklenen katman sayısı `-ngl` ile ayarlanır; betik 2 GB kartta 12, 4 GB kartta 24 seçer. Bellek hatası alırsan `~/.config/systemd/user/llama-server.service` içinde azalt, sonra `systemctl --user daemon-reload && systemctl --user restart llama-server`.

Modelin ne kadarının kartta çalıştığını görmek için model yüklüyken `ollama ps` çalıştır ve PROCESSOR sütununa bak.

## Sorun giderme

| Belirti | Olası neden | Çözüm |
| --- | --- | --- |
| `opencode: command not found` | PATH güncellenmedi | `source ~/.bashrc` ya da yeni terminal |
| NVIDIA modeli hata veriyor | OpenCode'un yeni sürümleri NVIDIA'nın reddettiği bir parametre gönderebiliyor (issue #49240) | `/models` ile başka bir NVIDIA modeline geç |
| DeepSeek düşünen modeli takılıyor | Bilinen sorun (issue #24264) | Qwen Coder, Kimi ya da GLM kullan |
| `429` ya da "rate limit" | Ücretsiz sınır doldu | `/models` ile başka sağlayıcıya geç |
| Yerel model dosya değiştirmiyor | Model araç çağırmayı desteklemiyor | `qwen3:4b` ya da `qwen2.5-coder` kullan; kontrol: `ollama show <model>` çıktısında `tools` |
| Yerel model saçmalıyor ya da talimatı unutuyor | Bağlam penceresi küçük | `OLLAMA_CONTEXT_LENGTH` en az 16384 olmalı |
| Yerel model çok yavaş | Model işlemcide çalışıyor | Daha küçük model (3b) ya da bulut sağlayıcı |
| `ollama ps` 100% CPU diyor | Kart Kepler ya da sürücü eski | `nvidia-smi` ile compute ve sürücüyü kontrol et |
| llama.cpp başlamıyor | Model henüz iniyor ya da bellek yetmiyor | `journalctl --user -fu llama-server` ile izle, `-ngl` değerini azalt |
| LM Studio açılmıyor | AppImage için FUSE eksik | `sudo apt install libfuse2t64` |
| OpenCode'da yerel model görünmüyor | Sunucu kapalıyken kuruldu | Sunucuyu başlat, sonra `bash araclar/opencode-kurulum.sh --esitle` |

Bir hatayı çözemezsen OpenCode'a hatanın tam metnini yapıştır ve plan modunda nedenini sor.

## Gizlilik ve güvenlik

Kredi kartı istemeyen ücretsiz katmanların çoğu gönderdiğin kodu model eğitiminde kullanabilir; gizli bir proje için tek güvenli seçenek yerel modellerdir.

- Şifre, API anahtarı, `.env` dosyası ya da müşteri verisi içeren dosyaları bulut modellerine gönderme.
- Anahtarlar yalnız `~/.local/share/opencode/auth.json` dosyasında durur (izin 600). Bu dosyayı Git'e ekleme ve paylaşma.
- Yerel sunucuları (Ollama, llama.cpp, LM Studio, Jan) yalnız `127.0.0.1` üzerinde dinlet; `0.0.0.0` ayarı ağdaki herkese kimlik doğrulamasız erişim açar.
- Build modunda değişiklikleri uygulamadan önce gözden geçir; çalışmaya başlamadan önce Git'e commit et ki geri alabilesin.
- Yapay zekânın yazdığı C kodunu derle, uyarıları okuyup test et: bellek ve işaretçi hataları küçük modellerde sık görülür. `-fsanitize=address,undefined` ile derlemek bu hataları yakalar.

## Kaynaklar

Rakamlar web arama sonuçlarından alındı; sayfaların çoğu doğrudan açılamadığı için yaklaşık kabul et. Ücretsiz sınırlar ve model listeleri sık değişir.

- [OpenCode sağlayıcıları](https://opencode.ai/docs/providers/) · [OpenCode Zen](https://opencode.ai/docs/zen/)
- [NVIDIA NIM](https://build.nvidia.com/) · [NVIDIA'yı OpenCode'a ekleme rehberi](https://gist.github.com/syntaxhacker/bd3014c383bf7247bb982acb91d732d2)
- [Ücretsiz LLM API'leri karşılaştırması (OpenRouter)](https://openrouter.ai/blog/tutorials/free-llm-apis-compared/) · [Ücretsiz API katmanları 2026](https://ianlpaterson.com/blog/free-llm-api-2026/)
- [Ollama donanım desteği](https://docs.ollama.com/gpu) · [Ollama ile OpenCode](https://docs.ollama.com/integrations/opencode) · [Ollama SSS](https://docs.ollama.com/faq) · [Ollama varsayılan bağlamı](https://multigrid.ai/learn/ollama-default-context-limit)
- [GeForce 800M serisi](https://en.wikipedia.org/wiki/GeForce_800M_series) · [GTX 860M özellikleri](https://www.techpowerup.com/198554/nvidia-geforce-gtx-860m-detailed)
- [llama.cpp sürümleri](https://github.com/ggml-org/llama.cpp/releases) · [LM Studio](https://lmstudio.ai/download) · [Jan yerel API sunucusu](https://www.jan.ai/docs/desktop/api-server)
- [En iyi açık kodlama modelleri 2026 (Morph)](https://www.morphllm.com/best-open-source-coding-model-2026) · [Qwen2.5-Coder teknik raporu](https://arxiv.org/html/2409.12186v3) · [Yerel kodlama modelleri karşılaştırması](https://dev.to/jovan_chan_9500711396d4e6/best-local-coding-llm-in-2026-qwen25-coder-vs-deepseek-coder-v2-vs-codestral-45g8) · [En iyi Ollama modelleri (Morph)](https://www.morphllm.com/best-ollama-models)
- [OpenCode NVIDIA sorunu #49240](https://github.com/anomalyco/opencode/issues/49240) · [OpenCode DeepSeek sorunu #24264](https://github.com/anomalyco/opencode/issues/24264)
