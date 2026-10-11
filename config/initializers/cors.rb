# CORS: permite que el front-end del TP2 (que corre en otro origen, ej.
# http://localhost:5173 con Vite) consuma la API desde el navegador.
# Solo se habilita para /api/*: el back-office sigue siendo same-origin.
#
# Los orígenes permitidos se configuran con FRONTEND_ORIGINS (separados
# por coma). No se usan cookies (la auth es por header Authorization),
# así que no hace falta credentials: true.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173").split(",").map(&:strip))

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :patch, :put, :delete, :options, :head ]
  end
end
