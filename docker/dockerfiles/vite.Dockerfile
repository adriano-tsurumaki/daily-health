FROM daily-health-base:dev

USER root

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

EXPOSE 3036
CMD ["bin/vite", "dev"]
