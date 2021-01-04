//
//  Sample Data.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 30.12.2020.
//

import Foundation

extension TokenizedReportViewModel {
    static var sample = TokenizedReportViewModel(reportContent: TextViewModel.ReportContent.sample)

    static var sample2 = TokenizedReportViewModel(reportContent: TextViewModel.ReportContent.sample2)
}

extension TextViewModel.ReportContent {
    static var sample: TextViewModel.ReportContent = {
        let headerString = TokenizedReportHeaderModel.sampleString

        let groups = [TokenizedReportGroupModel.sampleString,
                      TokenizedReportGroupModel.sampleString2]

        let footerString = TokenizedReportFooterModel.sampleString

        return TextViewModel.ReportContent(headerString: headerString, groups: groups, footerString: footerString)
    }()

    static var sample2: TextViewModel.ReportContent = {
        let headerString = TokenizedReportHeaderModel.sampleString

        let groups = [TokenizedReportGroupModel.sampleString,
                      TokenizedReportGroupModel.sampleString2]

        let footerString = TokenizedReportFooterModel.sampleString2

        return TextViewModel.ReportContent(headerString: headerString, groups: groups, footerString: footerString)
    }()
}

extension TokenizedReportHeaderModel {
    static var sample = TokenizedReportHeaderModel(headerString: sampleString)
    static var sampleString = """
            Название объекта: Саперави Аминьевка
            Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

            Статья расхода:    Сумма расхода:    План %     Факт %
            """
}

extension TokenizedReportGroupModel {
    static var sample = TokenizedReportGroupModel(groupString: sampleString)
    static var sampleString = """
            Прочие расходы:        15%    16.5%
            1.Налоговые платежи     26.964
            2.Банковское обслуживание    6.419
            3.Юридическое сопровождение    40.000
            4.Банковская комиссия 1.6% за эквайринг    26.581
            5.Тайный гость    -----------------------------
            9.Реклама и IT поддержка    65.000 (не iiko)
            10.Обслуживание пожарной охраны    -----------------------------
            11.Вневедомственная охрана помещения    -----------------------------
            12.Интернет    7.701+4.500
            13.Дезобработка помещения    -----------------------------
            14. РПК Ника (крепления д/телевизоров и монтаж)    30.000
            15.Аренда зарядных устройств и раций    ----------------------------
            27. Сервис Гуру (система аттестации, за 1 год)    12.655
            ИТОГ:    402.520
            """

    static var sample2 = TokenizedReportGroupModel(groupString: sampleString2)
    static var sampleString2 = """
            Прочие расходы:        15%    16.5%
            1.Налоговые платежи     26.964
            2.Банковское обслуживание    6.419
            3.Юридическое сопровождение    40.000
            ИТОГ:    73.383
            """
}

extension TokenizedReportFooterModel {
    static var sample = TokenizedReportFooterModel(footerString: sampleString)
    static var sampleString = """
            ИТОГ всех расходов за месяц:    2.343.392р 37к
            Фактический остаток:    96.628р 63к    20%
                Минус с августа переходит 739.626р 06к
            ИТОГ:    Минус 642.997р 43к
            """

    static var sample2 = TokenizedReportFooterModel(footerString: sampleString2)
    static var sampleString2 = """
            ИТОГ всех расходов за месяц:    1.677.077р46к

            Фактический остаток:    -609.230р46к    20%
                -173.753 остаток с июня
                -28.000 субсидия, поступила в июле
            ИТОГ:    -407.477р46к

            """
}
