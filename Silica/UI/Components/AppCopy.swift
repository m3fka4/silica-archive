import Foundation

struct AppCopy {
    let language: AppLanguage

    var isRussian: Bool { language.usesRussian }

    func callAsFunction(_ key: Key) -> String {
        isRussian ? key.ru : key.en
    }

    struct Key {
        let en: String
        let ru: String
    }

    static let compressSmarter = Key(en: "Compress smarter.", ru: "Сжимайте умнее.")
    static let dropAnything = Key(en: "Drop anything. Silica will find the best way.", ru: "Перетащите файлы. Silica сама выберет лучший способ.")
    static let everythingLocal = Key(en: "Everything stays on your Mac.", ru: "Всё остаётся на вашем Mac.")
    static let smart = Key(en: "Smart", ru: "Smart")
    static let archive = Key(en: "Archive", ru: "Архивы")
    static let images = Key(en: "Images", ru: "Изображения")
    static let lens = Key(en: "Lens", ru: "Lens")
    static let history = Key(en: "History", ru: "История")
    static let profiles = Key(en: "Profiles", ru: "Профили")
    static let settings = Key(en: "Settings", ru: "Настройки")
    static let chooseFiles = Key(en: "Choose Files", ru: "Выбрать файлы")
    static let start = Key(en: "Start", ru: "Запустить")
    static let onboardingTitle = Key(en: "Set up Silica", ru: "Настройка Silica")
    static let onboardingSubtitle = Key(en: "A few defaults so Silica feels right from the first launch.", ru: "Несколько настроек, чтобы Silica сразу работала удобно.")
    static let language = Key(en: "Language", ru: "Язык")
    static let appearance = Key(en: "Appearance", ru: "Тема")
    static let defaultFormat = Key(en: "Default archive format", ru: "Формат архива по умолчанию")
    static let privateMode = Key(en: "Private Mode", ru: "Приватный режим")
    static let quickPanel = Key(en: "Quick Panel", ru: "Быстрая панель")
    static let skip = Key(en: "Skip", ru: "Пропустить")
    static let finish = Key(en: "Finish", ru: "Готово")
    static let imagePreview = Key(en: "Preview", ru: "Предпросмотр")
    static let noPreview = Key(en: "Choose images to see a preview.", ru: "Выберите изображения, чтобы увидеть предпросмотр.")
    static let create = Key(en: "Create", ru: "Создать")
    static let extract = Key(en: "Extract", ru: "Распаковать")
}

extension SidebarSection {
    func title(language: AppLanguage) -> String {
        let copy = AppCopy(language: language)
        switch self {
        case .smart: return copy(.smart)
        case .archive: return copy(.archive)
        case .images: return copy(.images)
        case .lens: return copy(.lens)
        case .history: return copy(.history)
        case .profiles: return copy(.profiles)
        case .settings: return copy(.settings)
        }
    }
}

extension AppCopy.Key {
    static let compressSmarter = AppCopy.compressSmarter
    static let dropAnything = AppCopy.dropAnything
    static let everythingLocal = AppCopy.everythingLocal
    static let smart = AppCopy.smart
    static let archive = AppCopy.archive
    static let images = AppCopy.images
    static let lens = AppCopy.lens
    static let history = AppCopy.history
    static let profiles = AppCopy.profiles
    static let settings = AppCopy.settings
    static let chooseFiles = AppCopy.chooseFiles
    static let start = AppCopy.start
    static let onboardingTitle = AppCopy.onboardingTitle
    static let onboardingSubtitle = AppCopy.onboardingSubtitle
    static let language = AppCopy.language
    static let appearance = AppCopy.appearance
    static let defaultFormat = AppCopy.defaultFormat
    static let privateMode = AppCopy.privateMode
    static let quickPanel = AppCopy.quickPanel
    static let skip = AppCopy.skip
    static let finish = AppCopy.finish
    static let imagePreview = AppCopy.imagePreview
    static let noPreview = AppCopy.noPreview
    static let create = AppCopy.create
    static let extract = AppCopy.extract
}
