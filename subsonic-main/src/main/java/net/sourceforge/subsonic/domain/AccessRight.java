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
package net.sourceforge.subsonic.domain;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a Security Group.
 *
 */
public class AccessRight {

    private int musicfolder_id;
//    private int enabled = 0;
    
    private boolean isEnabled;
    
	public AccessRight(Integer musicfolder_id, boolean isEnabled) {
		this.setMusicfolder_id(musicfolder_id);
        this.isEnabled = isEnabled;
    }
    
    public AccessRight() {
	}

	/**
	 * @return the isEnabled
	 */
	public boolean isEnabled() {
		return isEnabled;
	}

	/**
	 * @param isEnabled the isEnabled to set
	 */
	public void setEnabled(boolean isEnabled) {
		this.isEnabled = isEnabled;
	}

	/**
	 * @return the musicfolder_id
	 */
	public int getMusicfolder_id() {
		return musicfolder_id;
	}

	/**
	 * @param musicfolder_id the musicfolder_id to set
	 */
	public void setMusicfolder_id(int musicfolder_id) {
		this.musicfolder_id = musicfolder_id;
	}

}