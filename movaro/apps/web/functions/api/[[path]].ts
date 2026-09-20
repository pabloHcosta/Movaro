interface PagesContext {
  request: Request;
  params: { path?: string | string[] };
}

const API_ORIGIN = 'https://movaro-production.up.railway.app';

export const onRequest = async ({ request, params }: PagesContext) => {
  const path = Array.isArray(params.path) ? params.path.join('/') : (params.path ?? '');
  const incomingUrl = new URL(request.url);
  const upstreamUrl = new URL(`/api/${path}${incomingUrl.search}`, API_ORIGIN);

  return fetch(new Request(upstreamUrl, request));
};
