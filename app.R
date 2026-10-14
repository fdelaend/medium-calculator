# Stressor medium calculator
# Computes how much of each intermediate stock solution to add to WC medium to
# reach target stressor concentrations in microcosm wells.
#
# Run in RStudio with "Run App", or from R:  shiny::runApp("path/to/medium-calculator")
# Files in R/ (calc.R, i18n.R) are loaded automatically by Shiny.

library(shiny)
library(bslib)
library(DT)

# ---- helpers -------------------------------------------------------------

i18n <- function(key) span(`data-i18n` = key, tr(key, "en"))

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || (length(a) == 1 && is.na(a))) b else a

pct <- function(x, digits = 1) ifelse(is.na(x), "—", paste0(formatC(100 * x, format = "f", digits = digits), " %"))

signif_fmt <- function(x) {
  ifelse(is.na(x), "—", format(signif(x, 3), big.mark = " ", scientific = FALSE, trim = TRUE, drop0trailing = TRUE))
}

# concentration of one stressor in the units the user thinks in
display_conc <- function(id, base_value, s) {
  r <- s[s$id == id, ]
  f <- function(u) paste(signif_fmt(from_base(base_value, u, id, r)), unit_label(u, id))
  if (r$kind == "dose") {
    paste(f("xWC"), f("mgEl/L"), f("mg/L"), sep = " \u00b7 ")
  } else if (id == "NaCl") {
    paste(f("mgEl/L"), f("mg/L"), sep = " \u00b7 ")
  } else {
    f(r$target_unit)
  }
}

unit_choices <- function(units, id) setNames(units, vapply(units, unit_label, "", id = id))

issue_text <- function(iss, lang, short = FALSE) {
  pre <- if (short) "is_" else "i_"
  t <- function(code) tr(paste0(pre, code), lang)
  names_of <- function(ids) paste(if (short) ids else st_name(ids, lang), collapse = ", ")
  switch(iss$code,
    over_volume  = sprintf(t("over_volume"), pct(iss$value)),
    weak_stock   = sprintf(t("weak_stock"), names_of(iss$ids)),
    singular     = t("singular"),
    small_volume = sprintf(t("small_volume"), iss$value, names_of(iss$ids)),
    wc_diluted   = sprintf(t("wc_diluted"), pct(iss$value)),
    nutrient_off = paste(vapply(seq_along(iss$ids), function(k)
      sprintf(t("nutrient_off"), if (short) iss$ids[k] else st_name(iss$ids[k], lang), pct(iss$value[k])), ""),
      collapse = if (short) "; " else " "),
    iss$code)
}

status_label <- function(status, lang) vapply(status, function(x) tr(paste0("st_", x), lang), "")

# DataTables interface text
dt_lang <- function(L) {
  if (L != "fr") return(list())
  list(search = "Rechercher :", lengthMenu = "Afficher _MENU_ lignes",
       info = "Lignes _START_ \u00e0 _END_ sur _TOTAL_", infoEmpty = "Aucune ligne",
       zeroRecords = "Aucun r\u00e9sultat", infoFiltered = "(filtr\u00e9 sur _MAX_)",
       paginate = list(first = "Premier", previous = "Pr\u00e9c\u00e9dent", `next` = "Suivant", last = "Dernier"))
}

status_colors <- c(ok = "#d9efe4", warning = "#fbefd0", infeasible = "#f6d6d3")

# ---- UI ------------------------------------------------------------------

defaults <- default_settings()

stock_row <- function(i) {
  r <- defaults[i, ]
  id <- r$id
  is_dose <- r$kind == "dose"
  tags$tr(
    tags$td(tags$strong(i18n(paste0("st_", id)))),
    tags$td(if (is_dose) div(class = "d-flex gap-1 align-items-center",
      numericInput(paste0("wc_", id), NULL, r$wc_dose, min = 0, step = 0.1, width = "70px"),
      span(class = "small", i18n("wc_of")),
      numericInput(paste0("wcs_", id), NULL, r$wc_stock_gL, min = 0, width = "90px"),
      span(class = "small", i18n("wc_stock_txt"))
    ) else "\u2014"),
    tags$td(div(class = "d-flex gap-1 align-items-center",
      numericInput(paste0("stock_", id), NULL, r$stock_value, min = 0, width = "100px"),
      selectInput(paste0("sunit_", id), NULL, unit_choices(STOCK_UNITS[[id]], id), r$stock_unit, width = "150px")
    )),
    tags$td(selectInput(paste0("solv_", id), NULL, c("WC medium" = "WC", "MilliQ water" = "water"), r$stock_solvent, width = "140px")),
    tags$td(div(class = "d-flex gap-1 align-items-center",
      numericInput(paste0("target_", id), NULL, r$target_value, min = 0, width = "100px"),
      selectInput(paste0("tunit_", id), NULL, unit_choices(TARGET_UNITS[[id]], id), r$target_unit, width = "150px"),
      span(class = "small", i18n(if (is_dose) "total_in_well" else "added"))
    ))
  )
}

js <- "
Shiny.addCustomMessageHandler('setLang', function(d) {
  document.querySelectorAll('[data-i18n]').forEach(function(el) {
    var k = el.getAttribute('data-i18n');
    if (d[k] !== undefined) el.textContent = d[k];
  });
});
"

css <- "
.stock-table td { vertical-align: middle; padding: .35rem .5rem; }
.stock-table .form-group { margin-bottom: 0; }
.stock-table .shiny-input-container { margin-bottom: 0; }
.lang-switch .form-group { margin: 0; }
.lang-switch .shiny-options-group { margin: 0; }
.lang-switch label { color: #fff; }
.status-box { border-radius: .5rem; padding: .75rem 1rem; margin-bottom: 1rem; font-weight: 500; }
.status-ok { background: #d9efe4; } .status-warning { background: #fbefd0; } .status-infeasible { background: #f6d6d3; }
.totalvol { font-size: 1.4rem; font-weight: 600; }
table.recipe td, table.recipe th { padding: .4rem .6rem; }
td.remarks-col { min-width: 260px; }
"

ui <- page_navbar(
  title = i18n("app_title"),
  theme = bs_theme(version = 5, primary = "#2a6f62"),
  bg = "#2a6f62", inverse = TRUE, fillable = FALSE,
  header = tags$head(tags$script(HTML(js)), tags$style(HTML(css))),

  nav_panel(
    title = i18n("tab_stocks"),
    card(
      card_header(i18n("tab_stocks")),
      p(class = "text-muted", i18n("stocks_intro")),
      div(class = "table-responsive",
        tags$table(class = "table stock-table",
          tags$thead(tags$tr(
            tags$th(i18n("h_stressor")), tags$th(i18n("h_wc_dose")), tags$th(i18n("h_stock")),
            tags$th(i18n("h_solvent")), tags$th(i18n("h_target")))),
          tags$tbody(lapply(seq_len(nrow(defaults)), stock_row))
        )
      ),
      p(class = "small text-muted", i18n("np_note")),
      div(class = "d-flex gap-2 flex-wrap",
        downloadButton("save_settings", i18n("save_settings"), class = "btn-sm btn-outline-secondary"),
        div(style = "max-width: 260px;", fileInput("load_settings", NULL, accept = ".csv", buttonLabel = i18n("load_settings"))),
        actionButton("reset", i18n("reset"), class = "btn-sm btn-outline-secondary", style = "height: fit-content;")
      )
    ),
    layout_columns(
      col_widths = c(8, 4),
      card(
        card_header(i18n("h_checks")),
        p(class = "text-muted", i18n("checks_intro")),
        DTOutput("checks")
      ),
      card(
        card_header(i18n("general")),
        numericInput("max_frac", i18n("max_frac"), 2, min = 0.1, max = 50, step = 0.5),
        numericInput("min_pip", i18n("min_pip"), 2, min = 0, step = 0.5),
        numericInput("min_wc", i18n("min_wc"), 95, min = 0, max = 100, step = 1)
      )
    )
  ),

  nav_panel(
    title = i18n("tab_single"),
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        width = 320,
        checkboxGroupInput("mix", i18n("choose_st"),
          choiceNames = lapply(CHEM_IDS, function(i) i18n(paste0("st_", i))),
          choiceValues = CHEM_IDS, selected = c("Gly", "Tyl")),
        numericInput("n_wells", i18n("n_wells"), 12, min = 1, step = 1),
        numericInput("well_vol", i18n("well_vol"), 6, min = 0.1, step = 0.5),
        numericInput("margin", i18n("margin"), 0, min = 0, step = 5),
        div(i18n("total_vol"), ":"),
        div(class = "totalvol", textOutput("total_vol", inline = TRUE))
      ),
      uiOutput("single_status"),
      card(
        card_header(i18n("recipe")),
        tableOutput("single_recipe"),
        p(class = "text-muted small", i18n("order_hint"))
      ),
      uiOutput("single_issues")
    )
  ),

  nav_panel(
    title = i18n("tab_plan"),
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        width = 330,
        p(class = "small text-muted", i18n("plan_intro")),
        checkboxGroupInput("pool", i18n("pool"),
          choiceNames = lapply(ALL_IDS, function(i) i18n(paste0("st_", i))),
          choiceValues = ALL_IDS, selected = ALL_IDS),
        checkboxGroupInput("levels", i18n("levels"), choices = 1:8, selected = c(2, 4, 6), inline = TRUE),
        numericInput("per_level", i18n("per_level"), 0, min = 0, step = 1),
        numericInput("seed", i18n("seed"), 1, step = 1),
        checkboxInput("control", i18n("control"), TRUE),
        numericInput("reps", i18n("replicates"), 3, min = 1, step = 1),
        numericInput("well_vol_plan", i18n("well_vol"), 6, min = 0.1, step = 0.5),
        numericInput("margin_plan", i18n("margin"), 10, min = 0, step = 5),
        downloadButton("download_plan", i18n("download_xlsx"), class = "btn-primary")
      ),
      uiOutput("plan_summary"),
      navset_tab(
        nav_panel(i18n("h_recipes"), div(class = "pt-3", DTOutput("plan_recipes"))),
        nav_panel(i18n("h_treatments"), div(class = "pt-3", DTOutput("plan_treatments")))
      )
    )
  ),

  nav_panel(title = i18n("tab_help"), card(uiOutput("help"))),

  nav_spacer(),
  nav_item(div(class = "lang-switch",
    radioButtons("lang", NULL, c("EN" = "en", "FR" = "fr"), "en", inline = TRUE)))
)

# ---- server --------------------------------------------------------------

server <- function(input, output, session) {

  lang <- reactive(input$lang %||% "en")

  observeEvent(lang(), {
    session$sendCustomMessage("setLang", dict_for(lang()))
    solv_choices <- setNames(c("WC", "water"), c(tr("solv_WC", lang()), tr("solv_water", lang())))
    for (id in CHEM_IDS)
      updateSelectInput(session, paste0("solv_", id), choices = solv_choices,
                        selected = isolate(input[[paste0("solv_", id)]]))
  })

  # current settings as a data frame
  settings <- reactive({
    s <- defaults
    for (k in seq_len(nrow(s))) {
      id <- s$id[k]
      if (s$kind[k] == "dose") {
        s$wc_dose[k]     <- input[[paste0("wc_", id)]] %||% s$wc_dose[k]
        s$wc_stock_gL[k] <- input[[paste0("wcs_", id)]] %||% s$wc_stock_gL[k]
      }
      s$stock_value[k]   <- input[[paste0("stock_", id)]] %||% s$stock_value[k]
      s$stock_solvent[k] <- input[[paste0("solv_", id)]] %||% s$stock_solvent[k]
      s$target_value[k]  <- input[[paste0("target_", id)]] %||% s$target_value[k]
      s$stock_unit[k]  <- input[[paste0("sunit_", id)]] %||% s$stock_unit[k]
      s$target_unit[k] <- input[[paste0("tunit_", id)]] %||% s$target_unit[k]
    }
    s
  })

  # When a unit is changed, convert the number so the concentration stays the same.
  prev_unit <- new.env()
  for (id0 in CHEM_IDS) for (side0 in c("sunit", "tunit")) local({
    id <- id0; side <- side0
    uid <- paste0(side, "_", id)
    vid <- paste0(if (side == "sunit") "stock_" else "target_", id)
    assign(uid, defaults[[if (side == "sunit") "stock_unit" else "target_unit"]][defaults$id == id], envir = prev_unit)
    observeEvent(input[[uid]], {
      new <- input[[uid]]
      old <- get(uid, envir = prev_unit)
      assign(uid, new, envir = prev_unit)
      v <- isolate(input[[vid]])
      if (!identical(old, new) && is.numeric(v) && !is.na(v)) {
        r <- isolate(settings())
        r <- r[r$id == id, ]
        updateNumericInput(session, vid, value = signif(from_base(to_base(v, old, id, r), new, id, r), 6))
      }
    }, ignoreInit = TRUE)
  })

  min_pip <- reactive(input$min_pip %||% 2)
  min_wc  <- reactive((input$min_wc %||% 95) / 100)

  # -- save / load / reset settings
  output$save_settings <- downloadHandler(
    filename = function() paste0("medium-settings-", Sys.Date(), ".csv"),
    content = function(file) utils::write.csv(settings()[, c("id", "wc_dose", "wc_stock_gL", "stock_value", "stock_unit", "stock_solvent", "target_value", "target_unit")], file, row.names = FALSE, fileEncoding = "UTF-8")
  )

  apply_settings <- function(s) {
    for (k in seq_len(nrow(s))) {
      id <- s$id[k]
      if (!id %in% CHEM_IDS) next
      kind <- defaults$kind[defaults$id == id]
      if (kind == "dose") {
        updateNumericInput(session, paste0("wc_", id), value = s$wc_dose[k])
        updateNumericInput(session, paste0("wcs_", id), value = s$wc_stock_gL[k])
      }
      # the unit observers must not convert loaded values
      assign(paste0("sunit_", id), s$stock_unit[k], envir = prev_unit)
      assign(paste0("tunit_", id), s$target_unit[k], envir = prev_unit)
      updateNumericInput(session, paste0("stock_", id), value = s$stock_value[k])
      updateSelectInput(session, paste0("sunit_", id), selected = s$stock_unit[k])
      updateSelectInput(session, paste0("solv_", id), selected = s$stock_solvent[k])
      updateNumericInput(session, paste0("target_", id), value = s$target_value[k])
      updateSelectInput(session, paste0("tunit_", id), selected = s$target_unit[k])
    }
  }

  observeEvent(input$load_settings, {
    s <- tryCatch(utils::read.csv(input$load_settings$datapath, stringsAsFactors = FALSE, fileEncoding = "UTF-8"),
                  error = function(e) NULL)
    if (is.null(s) || !all(c("id", "stock_value", "target_value") %in% names(s))) {
      showNotification("Could not read this settings file.", type = "error")
      return()
    }
    apply_settings(upgrade_settings(s))
  })

  observeEvent(input$reset, apply_settings(defaults))

  # -- tab 1: checks of the stocks
  output$checks <- renderDT({
    s <- settings(); L <- lang()
    mf <- (input$max_frac %||% 2) / 100
    d <- stock_diagnostics(s, mf)
    target_txt <- vapply(seq_len(nrow(d)), function(k) display_conc(d$id[k], d$target_base[k], s), "")
    stock_txt <- paste(signif_fmt(s$stock_value), mapply(unit_label, s$stock_unit, s$id))
    verdict <- ifelse(is.na(d$fraction_alone), tr("v_weak", L),
                ifelse(d$fraction_alone > mf * 1.0001, tr("v_high", L), tr("v_ok", L)))
    out <- data.frame(st_name(d$id, L), target_txt, stock_txt, pct(d$fraction_alone, 2),
                      paste(signif_fmt(d$suggested_stock), mapply(unit_label, d$stock_unit, d$id)), verdict,
                      stringsAsFactors = FALSE)
    names(out) <- c(tr("h_stressor", L), tr("c_target", L), tr("c_stock", L), tr("c_frac", L),
                    tr("c_suggest", L), tr("c_verdict", L))
    datatable(out, rownames = FALSE, options = list(dom = "t", ordering = FALSE), selection = "none", fillContainer = FALSE) |>
      formatStyle(tr("c_verdict", L), backgroundColor = styleEqual(
        c(tr("v_ok", L), tr("v_high", L), tr("v_weak", L)), unname(status_colors)))
  })

  # -- tab 2: one mixture
  single_volume <- reactive((input$n_wells %||% 0) * (input$well_vol %||% 0) * (1 + (input$margin %||% 0) / 100))
  output$total_vol <- renderText(paste(signif_fmt(single_volume()), "mL"))

  single <- reactive(solve_mixture(settings(), input$mix %||% character(0), single_volume(),
                                   min_pip(), min_wc()))

  output$single_status <- renderUI({
    r <- single(); L <- lang()
    msg <- if (length(input$mix) == 0) tr("s_wc_only", L) else tr(paste0("s_", r$status), L)
    div(class = paste0("status-box status-", r$status), msg)
  })

  output$single_recipe <- renderTable({
    r <- single(); s <- settings(); L <- lang()
    if (is.null(r$recipe)) return(NULL)
    rc <- r$recipe
    ids <- rc$id
    final <- vapply(ids, function(i) if (i == "WC") "" else display_conc(i, r$final[[i]], s), "")
    want  <- vapply(ids, function(i) if (i == "WC") "" else display_conc(i, r$target[[i]], s), "")
    out <- data.frame(c(st_name(ids, L), tr("total", L)),
                      c(fmt_volume(rc$volume_uL), fmt_volume(sum(rc$volume_uL))),
                      c(pct(rc$fraction, 2), pct(sum(rc$fraction), 0)),
                      c(final, ""), c(want, ""), stringsAsFactors = FALSE, check.names = FALSE)
    if (r$status == "infeasible") out[, 2] <- "—"
    names(out) <- c(tr("c_solution", L), tr("c_volume", L), tr("c_share", L), tr("c_final", L), tr("c_wanted", L))
    out
  }, striped = TRUE, class = "recipe", align = "lrrll")

  output$single_issues <- renderUI({
    r <- single(); L <- lang()
    if (length(r$issues) == 0) return(NULL)
    card(card_header(tr("c_remarks", L)),
         tags$ul(lapply(r$issues, function(i) tags$li(issue_text(i, L)))))
  })

  # -- tab 3: experiment plan
  plan <- reactive({
    pool <- intersect(ALL_IDS, input$pool %||% character(0))
    lv <- as.integer(input$levels %||% integer(0))
    n <- input$per_level %||% 0
    d <- make_design(lv, n_random = rep(if (n > 0) n else NA, length(lv)), pool = pool,
                     include_control = isTRUE(input$control), seed = input$seed %||% 1)
    req(nrow(d) > 0)
    media_plan(d, settings(), replicates = input$reps %||% 1, well_volume_mL = input$well_vol_plan %||% 6,
               margin = (input$margin_plan %||% 0) / 100, min_pipette_uL = min_pip(), min_wc_strength = min_wc())
  })

  stressor_text <- function(x, L) {
    vapply(x, function(s) { ids <- split_ids(s); if (length(ids) == 0) tr("none", L) else paste(st_name(ids, L), collapse = " + ") }, "")
  }

  recipe_table <- function(p, L, s, formatted = TRUE) {
    m <- p$media
    vols <- t(vapply(p$solutions, function(sol) {
      v <- setNames(rep(NA_real_, length(CHEM_IDS) + 1), c(CHEM_IDS, "WC"))
      if (!is.null(sol$recipe) && sol$status != "infeasible") v[sol$recipe$id] <- sol$recipe$volume_uL
      v
    }, numeric(length(CHEM_IDS) + 1)))
    remarks <- vapply(p$solutions, function(sol) paste(vapply(sol$issues, issue_text, "", lang = L, short = TRUE), collapse = "; "), "")
    out <- data.frame(m$medium, ifelse(m$chem_stressors == "", tr("none", L), gsub("+", " + ", m$chem_stressors, fixed = TRUE)), m$n_treatments, m$wells,
                      round(m$volume_mL, 1), stringsAsFactors = FALSE, check.names = FALSE)
    names(out) <- c(tr("c_medium", L), tr("c_chem", L), tr("c_ntreat", L), tr("c_wells", L), tr("c_vol_mL", L))
    vcols <- paste0(c(st_name(CHEM_IDS, L), st_name("WC", L)), if (formatted) "" else " (µL)")
    for (k in seq_along(vcols))
      out[[vcols[k]]] <- if (formatted) ifelse(is.na(vols[, k]), "", fmt_volume(vols[, k])) else round(vols[, k], 1)
    out[[tr("c_status", L)]] <- status_label(m$status, L)
    out[[tr("c_remarks", L)]] <- remarks
    out
  }

  output$plan_summary <- renderUI({
    p <- plan(); L <- lang()
    n_wells <- sum(p$media$wells)
    div(class = "status-box status-ok", style = if (any(p$media$status == "infeasible")) "background:#f6d6d3" else NULL,
      sprintf(tr("summary_plan", L), nrow(p$design), as.integer(n_wells), formatC(n_wells / 6, format = "f", digits = 1),
              nrow(p$media), sum(p$media$status == "infeasible")))
  })

  output$plan_recipes <- renderDT({
    p <- plan(); L <- lang()
    out <- recipe_table(p, L, settings())
    datatable(out, rownames = FALSE, selection = "none", fillContainer = FALSE,
              options = list(pageLength = 50, scrollX = TRUE, language = dt_lang(L),
                             columnDefs = list(list(className = "remarks-col", targets = ncol(out) - 1)))) |>
      formatStyle(names(out), valueColumns = tr("c_status", L),
        backgroundColor = styleEqual(status_label(names(status_colors), L), unname(status_colors)),
        boxShadow = "none")
  })

  output$plan_treatments <- renderDT({
    p <- plan(); L <- lang()
    d <- p$design
    out <- data.frame(d$treatment, d$n_stressors, stressor_text(d$stressors, L), d$medium, stringsAsFactors = FALSE)
    names(out) <- c(tr("c_treatment", L), tr("c_n", L), tr("c_stressors", L), tr("c_medium", L))
    datatable(out, rownames = FALSE, selection = "none", fillContainer = FALSE,
              options = list(pageLength = 50, language = dt_lang(L)))
  })

  output$download_plan <- downloadHandler(
    filename = function() paste0("medium-plan-", Sys.Date(), ".xlsx"),
    content = function(file) {
      p <- plan(); L <- lang(); s <- settings()
      d <- p$design
      treat <- data.frame(d$treatment, d$n_stressors, stressor_text(d$stressors, L), d$medium, stringsAsFactors = FALSE)
      names(treat) <- c(tr("c_treatment", L), tr("c_n", L), tr("c_stressors", L), tr("c_medium", L))
      sheets <- list(recipes = recipe_table(p, L, s, formatted = FALSE), treatments = treat,
                     settings = s[, c("id", "wc_dose", "wc_stock_gL", "stock_value", "stock_unit", "stock_solvent", "target_value", "target_unit")])
      names(sheets) <- c(tr("h_recipes", L), tr("h_treatments", L), tr("tab_stocks", L))
      names(sheets) <- substr(gsub("[^[:alnum:] &-]", "", names(sheets)), 1, 31)
      if (requireNamespace("writexl", quietly = TRUE)) {
        writexl::write_xlsx(sheets, file)
      } else {
        utils::write.csv(sheets[[1]], file, row.names = FALSE)
      }
    }
  )

  # -- help
  output$help <- renderUI({
    f <- file.path("help", paste0("help_", lang(), ".md"))
    if (file.exists(f)) shiny::markdown(paste(readLines(f, encoding = "UTF-8"), collapse = "\n"))
    else p("Help file not found.")
  })
}

shinyApp(ui, server)
