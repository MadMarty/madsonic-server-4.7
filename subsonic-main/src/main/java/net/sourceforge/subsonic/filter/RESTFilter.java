/*
 This file is part of Subsonic.

 Subsonic is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Subsonic is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Subsonic.  If not, see <http://www.gnu.org/licenses/>.

 Copyright 2009 (C) Sindre Mehus
 */
package net.sourceforge.subsonic.filter;

import net.sourceforge.subsonic.Logger;
import net.sourceforge.subsonic.controller.RESTController;
import org.springframework.web.bind.ServletRequestBindingException;
import org.springframework.web.util.NestedServletException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static net.sourceforge.subsonic.controller.RESTController.ErrorCode.GENERIC;
import static net.sourceforge.subsonic.controller.RESTController.ErrorCode.MISSING_PARAMETER;

/**
 * Intercepts exceptions thrown by RESTController.
 *
 * @author Sindre Mehus
 * @version $Revision: 1.1 $ $Date: 2006/03/01 16:58:08 $
 */
public class RESTFilter implements Filter {

    private static final Logger LOG = Logger.getLogger(RESTFilter.class);

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        try {
            chain.doFilter(req, res);
        } catch (Throwable x) {
            handleException(x, (HttpServletRequest) req, (HttpServletResponse) res);
        }
    }

    private void handleException(Throwable x, HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (x instanceof NestedServletException && x.getCause() != null) {
            x = x.getCause();
        }

        RESTController.ErrorCode code = (x instanceof ServletRequestBindingException) ? MISSING_PARAMETER : GENERIC;
        String msg = getErrorMessage(x);
        LOG.warn("Error in REST API: " + msg, x);

        RESTController.error(request, response, code, msg);
    }

    private String getErrorMessage(Throwable x) {
        if (x.getMessage() != null) {
            return x.getMessage();
        }
        return x.getClass().getSimpleName();
    }

    public void init(FilterConfig filterConfig) {
    }

    public void destroy() {
    }
}
