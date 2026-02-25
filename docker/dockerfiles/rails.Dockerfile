FROM daily-health-base:dev

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]