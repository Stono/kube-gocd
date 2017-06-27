module.exports = {
  karlstest: {
    fqdn: '127.0.0.1',
    redirectInsecure: false,
    useHsts: false,
    useCsp: false,
    default: true,
    upstreams: {
      root: 'master:8153'
    },
    paths: {
      '/': 'root'
    }
  }
};
